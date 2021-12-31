function Import-OktaConfiguration
{
[CmdletBinding(SupportsShouldProcess)]
param(
    [ValidateScript({Test-Path $_ -PathType Leaf})]
    [string] $JsonConfig = "C:\code\OktaPosh\OktaPosh\public\datacapture-ui.json",
    [HashTable] $Variables = @{ cluster = "nonprod"; domainSuffix = "dev" },
    [switch] $DumpConfig,
    [switch] $Quiet,
    [switch] $Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$script:existingGroups = @()

function addAuthServer {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([string])]
    param ($config)

    $authConfig = $config.authorizationServer
    $authServer = Get-OktaAuthorizationServer -Query $authConfig.name
    if ($authServer) {
        Write-Information "Found auth server '$($authConfig.name)'"
    } else {
        $authServer = New-OktaAuthorizationServer -Name $authConfig.name `
                                                  -Audiences $authConfig.audience `
                                                  -Description (getProp $authConfig "description" "Added By OktaPosh")
        if ($authServer -or $WhatIfPreference) {
            Write-Information "Added auth server '$($authConfig.name)'"
        } else {
            throw "Failed to create auth server '$($authConfig.name)'"
        }
    }
    if ($authServer -and $authServer.id) {
        return $authServer.Id
    } else {
        return "WhatIf"
    }
}

function addScopes( $config, $authServerId ) {
    $scopesConfig = @(getProp $config "scopes" @())
    if ($scopesConfig) {
        $existingScopeNames = @(Get-OktaScope -AuthorizationServerId $authServerId | Select-Object -ExpandProperty name)
        $scopeToAdd = $scopesConfig | Where-Object { $_.name -notin $existingScopeNames }
        if ($scopeToAdd) {
            $null = $scopeToAdd | New-OktaScope -AuthorizationServerId $authServerId
            Write-Information "  Scopes added: $($scopeToAdd.name -join ',')"
        } else {
            Write-Information "  All scopes found"
        }
    }
}

function addClaims( $config, $authServerId ) {
    $claimsConfig = @(getProp $config "claims" @())
    if ($claimsConfig) {
        $existingClaims = Get-OktaClaim -AuthorizationServerId $authServerId

        foreach ($claimConfig in $claimsConfig) {
            $claimType = normalizeClaimType (getProp $claimConfig "claimType" "RESOURCE")
            $claim = $existingClaims | Where-Object { ($_.name -eq $claimConfig.name) -and ($_.claimType -eq $claimType) }
            if ($claim) {
                Write-Information "  Found claim '$($claimConfig.Name)'"
            } else {
                $claim = New-OktaClaim -AuthorizationServerId $authServerId `
                                        -Name $claimConfig.name `
                                        -ValueType $claimConfig.valueType `
                                        -ClaimType $claimType `
                                        -Value $claimConfig.value `
                                        -Scopes @(getProp $claimConfig "scopes" @())
                Write-Information "  Added claim '$($claimConfig.Name)'"
            }
        }
    }
}

function addGroups ($config, $authServerId) {
    $groupConfigs = @(getProp $config "groups" @())
    $groupPrefix = ""
    if ($groupConfigs) {
        $script:existingGroups = @(Get-OktaGroup -q $groupPrefix)
        while (Test-OktaNext -ObjectName groups) { $script:existingGroups += Get-OktaGroup -Next; }
        if ($script:existingGroups) {
            $existingGroupNames = @($script:existingGroups.profile.name)
        } else {
            $existingGroupNames = @()
        }

        $groupToAdd = @($groupConfigs | Where-Object { $_.name -notin $existingGroupNames})
        Write-Information "Found $($existingGroupNames.count) groups for prefix '$groupPrefix*' and want $($groupConfigs.Count) will add $($groupToAdd.Count)"

        foreach ($group in $groupToAdd) {
            $script:existingGroups += New-OktaGroup -Name $group.Name
            Write-Information "  Added group '$($group.Name)'"
        }
        $existingScopeNames = @(Get-OktaScope -AuthorizationServerId $authServerId | Select-Object -ExpandProperty Name)
        $existingClaimNames = @(Get-OktaClaim -AuthorizationServerId $authServerId | Select-Object -ExpandProperty Name)
        foreach ($group in $groupConfigs) {
            if ((getProp $group "scope" "")) {
                if ($group.scope -in $existingScopeNames) {
                    Write-Information "  Found scope $($group.scope)"
                } else {
                    $null = New-OktaScope -AuthorizationServerId $authServerId `
                                        -Name $group.scope
                    Write-Information "  Added scope '$($group.scope)'"
                }
                if ($group.scope -in $existingClaimNames) {
                    Write-Information "  Found claim $($group.scope)"
                } else {
                    $null = New-OktaClaim -AuthorizationServerId $authServerId `
                                          -Name $group.scope `
                                          -ValueType "GROUPS" `
                                          -ClaimType "RESOURCE" `
                                          -GroupFilterType "EQUALS" `
                                          -Value $group.name `
                                          -Scopes @($group.scope)

                    Write-Information "  Added claim '$($group.scope)' with value $($group.name)"
                }
            }
        }
    }
}

function addServerApplications($config, $authServerId) {
    $appConfigs = @(getProp $config "serverApplications" @())
    foreach ($appConfig in $appConfigs) {
        $appName = $appConfig.name

        $app = Get-OktaApplication -Query $appName | Where-Object { $_.label -eq $appName }
        if ($app) {
            Write-Information "Found app '$appName'"
        } else {
            $app = New-OktaServerApplication -Label $appName `
                                             -SignOnMode (getProp $appConfig "signOnMode" "OPENID_CONNECT") `
                                             -Properties (convertToHashTable (getProp $appConfig "properties" $null))
            Write-Information "Added app '$appName'"
        }

        addPolicyAndRule (getProp $appConfig "policyName" "") $authServerId $app.Id "client_credentials" $appConfig.scopes
        addAppGroups $appConfig $app.Id
    }
}

function addAppGroups($appConfig, $appId) {
    $groupNames = @(getProp $appConfig "groups")
    Write-Debug "Found $($groupNames.Count) groupNames to add $($groupNames | out-string)"
    if ($groupNames) {
        $existingGroupIds = @((Get-OktaApplicationGroup -AppId $appId) | ForEach-Object { ($_._links.group.href -split '/')[-1] })
        while (Test-OktaNext -ObjectName "apps/$($appId)/groups" ) {
            $existingGroupIds += (Get-OktaApplicationGroup -AppId $appId -Next | ForEach-Object { ($_._links.group.href -split '/')[-1] } )
        }

        foreach ($missingGroup in ($groupNames | Where-Object { $script:existingGroups -and $_ -notin $script:existingGroups.profile.name})) {
            Write-Warning "Adding missing group configured only in app '$missingGroup'. Add to groups section to avoid warning"
            $script:existingGroups += New-OktaGroup -Name $missingGroup -Description "Added by OktaPosh"
        }
        $groupsToAdd = @($script:existingGroups | Where-Object { ($_.profile.name -in $groupNames) -and ($_.id -notin $existingGroupIds) })

        foreach ($group in $groupsToAdd) {
            $null = Add-OktaApplicationGroup -AppId $appId -GroupId $group.id
            Write-Information "  Added group to app '$($group.profile.name)'"
        }
    }
}

function addTrustedOrigins($config) {
    $originConfigs = @(getProp $config "origins" @())
    foreach ($origin in $originConfigs) {
        if (getProp $origin "origin" "") { # may have empty "additional"
            $name = (getProp $origin "name" $origin.origin)
            if ((Get-OktaTrustedOrigin -Filter "name eq `"$name`"")) {
                Write-Information "Found origin '$name' => '$($origin.origin)'"
            } else {
                $null = New-OktaTrustedOrigin -Name $name `
                                            -Origin $origin.origin `
                                            -CORS:(getProp $origin "cors" $true) `
                                            -Redirect:(getProp $origin "redirect" $true)
                Write-Information "Added origin '$name' => '$($origin.origin)'"
            }
        }
    }
}

function addSpaApplications($config, $authServerId) {

    $appConfigs = @(getProp $config "spaApplications" @())
    foreach ($appConfig in $appConfigs) {
        $appName = $appConfig.name

        $app = Get-OktaApplication -Query $appName | Where-Object { $_.label -eq $appName }
        if ($app) {
            Write-Information "Found and updating app '$appName' $($app.id)"
            $app.settings.oauthClient.redirect_uris = $appConfig.redirectUris
            setProp $app.settings.oauthClient "post_logout_redirect_uris" @(getProp $appConfig "postLogoutUris" @())
            setProp $app.settings.oauthClient "grant_types" (getProp $appConfig "grantTypes" $null)
            setProp $app.settings.oauthClient "initiate_login_uri" $appConfig.loginUri
            $app.settings.oauthClient.response_types = @()
            if ('implicit' -in $appConfig.grantTypes) {
                $app.settings.oauthClient.response_types += @('id_token', 'token')
            }
            if ('authorization_code' -in $appConfig.grantTypes) {
                $app.settings.oauthClient.response_types += 'code'
            }

            $app = Set-OktaApplication -Application $app
            $appId = $app.id
        } else {
            $app = New-OktaSpaApplication `
                        -Label $appName `
                        -RedirectUris $appConfig.redirectUris `
                        -LoginUri $appConfig.loginUri `
                        -PostLogoutUris @(getProp $appConfig "postLogoutUris" @()) `
                        -SignOnMode (getProp $appConfig "signOnMode" "OPENID_CONNECT") `
                        -Properties (convertToHashTable (getProp $appConfig "properties" $null)) `
                        -GrantTypes (getProp $appConfig "grantTypes" $null)
            $appId = "WhatIf"
            if ($app) {
                $appId = $app.id
            }
            Write-Information "Added app '$appName' $appId"
        }

        addPolicyAndRule (getProp $appConfig "policyName" "") $authServerId $appId $appConfig.grantTypes $appConfig.scopes
        addAppGroups $appConfig $appId
        addTrustedOrigins $appConfig
    }
}

function replaceVariables {
    [CmdletBinding()]
    param($JsonConfig,$Variables,$Force)

    $content = Get-Content $JsonConfig -Raw
    $config = ConvertFrom-Json $content
    $vars = convertToHashTable (getProp $config "variables" @())

    if ($Variables) {
        foreach ($override in $Variables.Keys) {
            $vars[$override] = $Variables[$override]
            Write-Verbose "Command line variable: $override = $($Variables[$override])"
        }
    }

    foreach ($key in $vars.Keys) {
        if ($vars[$key] -eq "" -or $vars[$key] -eq "{}") {
            Write-Debug "Replacing $($key) as empty array item"
            $content = $content -replace ",\s*`"\s*{{\s*$($key)\s*}}\s*`"", ""
        }
        $replacement = $vars[$key]

        if (Test-Path (Join-Path (Split-Path $JsonConfig -Parent) $vars[$key]) -PathType Leaf) {
            Write-Debug "Replacing $($key) with file content from '$($vars[$key])'"
            $replacement = Get-Content (Join-Path (Split-Path $JsonConfig -Parent) $vars[$key]) -Raw
            $content = $content -replace "`"\s*{{\s*$($key)\s*}}\s*`"", $replacement
        } else {
            Write-Debug "Replacing $($key) with '$($vars[$key])'"
            if ($replacement.StartsWith("{")) {
                $content = $content -replace "`"\s*{{\s*$($key)\s*}}\s*`"", $replacement
            } else {
                $content = $content -replace "{{\s*$($key)\s*}}", $replacement
            }
        }
    }
    if ($DumpConfig) {
        return $content
    } elseif (!$Force -and $content.Contains("{{")) {
        Write-Warning "After variable replacement, $JsonConfig contains {{."
        Write-Warning "Use -Force to run anyway."
        Write-Warning "Use -DumpConfig to see output"
        throw "ERROR: After variable replacement"
    }
    return ConvertFrom-Json $content
}

$config = replaceVariables -JsonConfig $JsonConfig -Variables $Variables -Force $Force
if ($DumpConfig) {
    $config
    if ($config.Contains("{{")) {
        Write-Error "ERROR: After variable replacement, $JsonConfig contains {{"
    }
    return
}


$prevInformationPreference = $InformationPreference
$InformationPreference = ternary $Quiet "SilentlyContinue" "Continue"
try {
    $script:existingGroups = @()

    $authServerId = addAuthServer $config

    addScopes $config.authorizationServer $authServerId

    addClaims $config.authorizationServer $authServerId

    addGroups $config $authServerId

    addServerApplications $config $authServerId

    addSpaApplications $config $authServerId

} catch {
    Write-Error "Error! $_`n$($_.ScriptStackTrace)"
} finally {
    $InformationPreference = $prevInformationPreference
}

}