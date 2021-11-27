<#
.EXAMPLE
Import-OktaConfiguration -JsonConfig C:\code\OktaPosh\OktaPosh\public\datacapture-ui.json -DumpConfig -Variables @{ cluster = "nonprod"; domainSuffix = "dev" }

Dump out the config to check on variable replacements

.EXAMPLE
Import-OktaConfiguration -JsonConfig C:\code\OktaPosh\OktaPosh\public\datacapture-ui.json -DumpConfig -Variables @{ cluster = "nonprod"; domainSuffix = "dev" }

Dump out the config to check on variable replacements
#>
function Import-OktaConfiguration
{
[CmdletBinding(SupportsShouldProcess)]
param(
    [ValidateScript({Test-Path $_ -PathType Leaf})]
    [string] $JsonConfig = "C:\code\OktaPosh\OktaPosh\public\datacapture-ui.json", #"C:\code\OktaPosh\OktaPosh\public\reliance-server.json",
    [HashTable] $Variables = @{ cluster = "nonprod"; domainSuffix = "dev" },
    [switch] $DumpConfig
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

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
            Write-Information "Created '$($authConfig.name)'"
        } else {
            throw "Failed to create '$($authConfig.name)'"
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
            $null = $scopes | New-OktaScope -AuthorizationServerId $authServerId `
                                            -Description (getProp $scope "description" "Added By OktaPosh") `
                                            -MetadataPublish:(getProp $scope "metadataPublish" $false)
            Write-Information "Scopes added: $($scopes -join ',')"
        } else {
            Write-Information "All scopes found"
        }
    }
}

function addClaims( $config, $authServerId ) {
    $claimsConfig = @(getProp $config "claims" @())
    foreach ($claimConfig in $claimsConfig) {
        $claim = Get-OktaClaim -AuthorizationServerId $authServerId -Query $claimConfig.name
        if ($claim) {
            Write-Information "Found '$($claimConfig.Name)' Claim"
        } else {
            $claim = New-OktaClaim -AuthorizationServerId $authServerId `
                                    -Name $claimConfig.name `
                                    -ValueType $claimConfig.valueType `
                                    -ClaimType (getProp $claimConfig "claimType" "RESOURCE") `
                                    -Value $claimConfig.value `
                                    -Scopes @(getProp $claimConfig "scopes" @())
            Write-Information "Added '$($claimConfig.Name)' Claim"
        }
    }
}

function addGroups ($config, $authServerId) {
    $groupConfigs = @(getProp $config "groups" @())
    $groupPrefix = ""
    if ($groupConfigs) {
        $existingGroups = @(Get-OktaGroup -q $groupPrefix)
        while (Test-OktaNext -ObjectName groups) { $existingGroups += Get-OktaGroup -Next; }
        if ($existingGroups) {
            $existingGroupNames = $existingGroups.profile.name
        } else {
            $existingGroupNames = @()
        }

        $groupToAdd = @($groupConfigs | Where-Object { $_.name -notin $existingGroupNames})
        Write-Information "Found $($existingGroupNames.count) groups for $groupPrefix* and want $($groupConfigs.Count) may add $($groupToAdd.Count)"

        foreach ($group in $groupToAdd) {
            $null = New-OktaGroup -Name $group.Name
            Write-Information "Added group '$group'"
        }
        foreach ($group in $groupConfigs) {
            if ((getProp $group "scope" "")) {
                if (Get-OktaScope -AuthorizationServerId $authServerId -Query $group.scope) {
                    Write-Information "    Found scope $($group.scope)"
                } else {
                    $null = New-OktaScope -AuthorizationServerId $authServerId `
                                        -Name $group.scope
                    Write-Information "    Added scope '$group.scope'"
                }
                if (Get-OktaClaim -AuthorizationServerId $authServerId -Query $group.name) {
                    Write-Information "    Found claim $($group.name)"
                } else {
                    $null = New-OktaClaim -AuthorizationServerId $authServerId `
                                          -Name $group.scope `
                                          -ValueType "GROUPS" `
                                          -ClaimType "RESOURCE" `
                                          -GroupFilterType "EQUALS" `
                                          -Value $group.name `
                                          -Scopes @($group.scope)

                    Write-Information "    Added claim '$group.name'"
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
                                             -Properties (convertToHashTable (getProp $appConfig "properties" $null))
            Write-Information "Added app '$appName'"
        }

        # create policies to restrict scopes per app
        $policyName = getProp $appConfig "policyName" ""
        if ($policyName) {
            $policy = Get-OktaPolicy -AuthorizationServerId $authServerId -Query $policyName
            if ($policy) {
                Write-Information "    Found '$($policyName)' Policy"
            } else {
                $policy = New-OktaPolicy -AuthorizationServerId $authServerId `
                                         -Name $policyName `
                                         -ClientIds $app.Id
                Write-Information "    Added '$($policyName)' Policy"
            }
            $rule = Get-OktaRule -AuthorizationServerId $authServerId `
                                 -PolicyId $policy.id `
                                 -Query "Allow $($policyName)"
            if ($rule) {
                Write-Information "    Found 'Allow $($policyName)' Rule"
                if (!(arraysEqual $rule.conditions.scopes.include $appConfig.scopes)) {
                    $rule.conditions.scopes.include = $appConfig.scopes
                    $null = Set-OktaRule -AuthorizationServerId $authServerId `
                                         -PolicyId $policy.id `
                                         -Rule $rule
                    Write-Information "    Updated rule's scopes"
                }
            } else {
                $rule = New-OktaRule -AuthorizationServerId $authServerId `
                                     -Name "Allow $($policyName)" `
                                     -PolicyId $policy.id `
                                     -Priority 1 `
                                     -GrantTypes client_credentials `
                                     -Scopes $appConfig.scopes
                Write-Information "    Added 'Allow $($policyName)' Rule"
            }
        }
    }
}

function addPolicyAndRule($config, $authServerId, $appId) {
    # create policies to restrict scopes per app
    $policyName = getProp $appConfig "policyName" ""
    if ($policyName) {
        $policy = Get-OktaPolicy -AuthorizationServerId $authServerId -Query $policyName
        if ($policy) {
            Write-Information "    Found '$($policyName)' Policy"
        } else {
            $policy = New-OktaPolicy -AuthorizationServerId $authServerId `
                                     -Name $policyName `
                                     -ClientIds $appId
            Write-Information "    Added '$($policyName)' Policy"
        }
        if (!$WhatIfPreference) {
            $rule = Get-OktaRule -AuthorizationServerId $authServerId `
                                -PolicyId $policy.id `
                                -Query "Allow $($policyName)"
        } else {
            $rule = $null
        }
        if ($rule) {
            Write-Information "    Found 'Allow $($policyName)' Rule"
            if (!(arraysEqual $rule.conditions.scopes.include $appConfig.scopes)) {
                $rule.conditions.scopes.include = $appConfig.scopes
                $null = Set-OktaRule -AuthorizationServerId $authServerId `
                                     -PolicyId $policy.id `
                                     -Rule $rule
                Write-Information "    Updated rule's scopes"
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
            Write-Information "    Added 'Allow $($policyName)' Rule"
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
                        -PostLogoutUris @(getProp $appConfig "postLogoutUris" @())
            $appId = "WhatIf"
            if ($app) {
                $appId = $app.id
            }
            Write-Information "Added app '$appName' $appId"
        }

        addPolicyAndRule $appConfig $authServerId $appId
    }
}

function replaceVariables($JsonConfig) {
    $content = Get-Content $JsonConfig -Raw
    $config = ConvertFrom-Json $content
    $vars = @(getProp $config "variables" @())

    if ($Variables) {
        foreach ($override in $Variables.Keys) {
            $vars += @{ name = $override; value = $Variables[$override] }
            Write-Verbose "Command line variable: $override = $($Variables[$override])"
        }
    }
    if ($vars) {
        foreach ($v in $vars) {
            $content = $content -replace "{{\s*$($v.name)\s*}}", $v.value
        }
        if ($DumpConfig) {
            return $content
        }
        return ConvertFrom-Json $content
    } else {
        return $config
    }
}
$config = replaceVariables $JsonConfig -Raw
if ($DumpConfig) {
    $config
    if ($config.Contains("{{")) {
        Write-Warning "After variable replacement, contains {{"
    }
    return
}

try {
    $authServerId = addAuthServer $config

    addScopes $config.authorizationServer $authServerId

    addClaims $config.authorizationServer $authServerId

    addGroups $config $authServerId

    addServerApplications $config $authServerId

    addSpaApplications $config $authServerId

} catch {
    Write-Error "Error! $_`n$($_.ScriptStackTrace)"
}

}