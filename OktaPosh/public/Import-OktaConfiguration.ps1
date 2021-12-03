function Import-OktaConfiguration
{
[CmdletBinding(SupportsShouldProcess)]
param(
    [ValidateScript({Test-Path $_ -PathType Leaf})]
    [string] $JsonConfig = "C:\code\OktaPosh\OktaPosh\public\datacapture-ui.json",
    [HashTable] $Variables = @{ cluster = "nonprod"; domainSuffix = "dev" },
    [switch] $DumpConfig,
    [switch] $Quiet
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$script:existingGroups = @()

function addAuthServer {
    [CmdletBinding(SupportsShouldProcess)]
    param ($config)

    $authConfig = $config.authorizationServer
    $authServer = Get-OktaAuthorizationServer -Query $authConfig.name
    if ($authServer) {
        Write-Information "Found auth server '$($authConfig.name)'"
    } else {
        $authServer = New-OktaAuthorizationServer -Name $authConfig.name `
                                                  -Audience $authConfig.audience `
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
        $existingScopes = Get-OktaScope -AuthorizationServerId $authServerId | Select-Object -ExpandProperty name
        $scopes = $scopesConfig | Where-Object { $_.name -notin $existingScopes }
        if ($scopes) {
            $null = $scopes | New-OktaScope -AuthorizationServerId $authServerId
            Write-Information "  Scopes added: $($scopes.name -join ',')"
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
        foreach ($group in $groupConfigs) {
            if ((getProp $group "scope" "")) {
                if (Get-OktaScope -AuthorizationServerId $authServerId -Query $group.scope) {
                    Write-Information "  Found scope $($group.scope)"
                } else {
                    $null = New-OktaScope -AuthorizationServerId $authServerId `
                                        -Name $group.scope
                    Write-Information "  Added scope '$($group.scope)'"
                }
                if (Get-OktaClaim -AuthorizationServerId $authServerId -Query $group.scope) {
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

        addPolicyAndRule $appConfig $authServerId $app.Id
        addAppGroups $appConfig $app.Id
    }
}

function addPolicyAndRule($config, $authServerId, $appId) {
    # create policies to restrict scopes per app
    $policyName = getProp $appConfig "policyName" ""
    if ($policyName) {
        $policy = Get-OktaPolicy -AuthorizationServerId $authServerId -Query $policyName
        if ($policy) {
            Write-Information "  Found policy '$($policyName)'"
        } else {
            $policy = New-OktaPolicy -AuthorizationServerId $authServerId `
                                     -Name $policyName `
                                     -ClientIds $appId
            Write-Information "  Added policy '$($policyName)'"
        }
        if (!$WhatIfPreference) {
            $rule = Get-OktaRule -AuthorizationServerId $authServerId `
                                -PolicyId $policy.id `
                                -Query "Allow $($policyName)"
        } else {
            $rule = $null
        }
        if ($rule) {
            Write-Information "  Found rule 'Allow $($policyName)'"
            if (!(arraysEqual $rule.conditions.scopes.include $appConfig.scopes)) {
                $rule.conditions.scopes.include = $appConfig.scopes
                $null = Set-OktaRule -AuthorizationServerId $authServerId `
                                     -PolicyId $policy.id `
                                     -Rule $rule
                Write-Information "  Updated rule's scopes"
            }
        } else {
            if (!$WhatIfPreference) {
                $rule = New-OktaRule -AuthorizationServerId $authServerId `
                                    -Name "Allow $($policyName)" `
                                    -PolicyId $policy.id `
                                    -Priority 1 `
                                    -GrantTypes client_credentials `
                                    -Scopes $appConfig.scopes
            }
            Write-Information "  Added rule 'Allow $($policyName)'"
        }
    }
}

function addAppGroups($appConfig, $appId) {
    $groupNames = @(getProp $appConfig "groups")
    Write-Debug "Found $($groupNames.Count) groupNames to add $($groupNames | out-string)"
    if ($groupNames) {
        $appGroupIds = @((Get-OktaApplicationGroup -AppId $appId) | Select-Object -ExpandProperty id)
        while (Test-OktaNext -ObjectName "apps/$($appId)/groups" ) { $appGroupIds += (Get-OktaApplicationGroup -AppId $appId -Next).id }

        $groups = @($script:existingGroups | Where-Object { $_.profile.name -in $groupNames })

        foreach ($group in ($groups | Where-Object { $_.id -notin $appGroupIds})) {
            $null = Add-OktaApplicationGroup -AppId $appId -GroupId $group.id
            Write-Information "  Added group to app '$($group.profile.name)'"
        }
    }
}

function addTrustedOrigins($config) {
    $originConfigs = @(getProp $config "origins" @())
    foreach ($origin in $originConfigs) {
        if (getProp $origin "origin" "") { # may have empty "additional"
            if (Get-OktaTrustedOrigin -Filter "origin eq `"$origin`"") {
                Write-Information "Found origin '$origin'"
            } else {
                $null = New-OktaTrustedOrigin -Name (getProp $origin "name" $origin.origin) `
                                            -Origin $origin.origin `
                                            -CORS:(getProp $origin "cors" $true) `
                                            -Redirect:(getProp $origin "redirect" $true)
                Write-Information "Added origin '$($origin.origin)'"
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
                        -GrantTypes (getProp $appConfig "grantTypes" $null) `
                        -PostLogoutUris @(getProp $appConfig "postLogoutUris" @())
            $appId = "WhatIf"
            if ($app) {
                $appId = $app.id
            }
            Write-Information "Added app '$appName' $appId"
        }

        addPolicyAndRule $appConfig $authServerId $appId
        addAppGroups $appConfig $appId
        addTrustedOrigins $appConfig
    }
}

function replaceVariables {
    [CmdletBinding()]
    param($JsonConfig)

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
        if ($vars[$key] -eq "") {
            Write-Debug "Replacing $($key) as empty array item"
            $content = $content -replace ",`"{{\s*$($key)\s*}}`"", ""
        }
        $replacement = $vars[$key]
        if (Test-Path (Join-Path (Split-Path $JsonConfig -Parent) $vars[$key]) -PathType Leaf) {
            Write-Debug "Replacing $($key) with file content from $($vars[$key])"
            $replacement = Get-Content (Join-Path (Split-Path $JsonConfig -Parent) $vars[$key]) -Raw
            $content = $content -replace "`"{{\s*$($key)\s*}}`"", $replacement
        } else {
            Write-Debug "Replacing $($key) with $($vars[$key])"
            $content = $content -replace "{{\s*$($key)\s*}}", $replacement
        }
    }
    if ($DumpConfig) {
        return $content
    }
    return ConvertFrom-Json $content
}

$config = replaceVariables $JsonConfig
if ($DumpConfig) {
    $config
    if ($config.Contains("{{")) {
        Write-Error "After variable replacement, $JsonConfig contains {{"
    }
    return
}

$prevInformationPreference = $InformationPreference
$InformationPreference = ternary $Quiet "SilentlyContinue" "Continue"
try {
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