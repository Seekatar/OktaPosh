function Import-OktaConfiguration
{
[CmdletBinding()]
param(
    [ValidateScript({Test-Path $_ -PathType Leaf})]
    [string] $JsonConfig = "C:\code\OktaPosh\OktaPosh\public\reliance-server.json"
)

Set-StrictMode -Version Latest

function getProp( $object, $name, $default = $null )
{
    if (Get-Member -InputObject $object -Name $name) {
        $object.$name
    } else {
        $default
    }
}

function addAuthServer($config) {
    $authConfig = $config.authorizationServer
    $authServer = Get-OktaAuthorizationServer -Query $authConfig.name
    if ($authServer) {
        Write-Information "Found '$($authConfig.name)'"
    } else {
        $authServer = New-OktaAuthorizationServer -Name $authConfig.name `
            -Audience $auth.audience `
            -Description (getProd $auth "description" "Added By OktaPosh")
        if ($authServer) {
            Write-Information "Created '$($authConfig.name)'"
        } else {
            throw "Failed to create '$($authConfig.name)'"
        }
    }
}

$config = ConvertFrom-Json (Get-Content $JsonConfig -Raw)

try {
    $authServer = addAuthServer $config

    $scopes = getProp $authConfig "scopes" @()
    if ($scopes) {
        $existingScopes = Get-OktaScope -AuthorizationServerId $authServer.id | Select-Object -ExpandProperty name
        $scopes = $scopes.name | Where-Object { $_ -notin $existingScopes }
        foreach ($scope in $scopes) {
            if ($scopes) {
                $null = $scopes | New-OktaScope -AuthorizationServerId $authServer.id -MetadataPublish (getProp $_ "metadataPublish" $false)
                Write-Information "Scopes added: $($scopes -join ',')"
            } else {
                Write-Information "All scopes found"
            }
        }
    }

    $claims = getProp $authConfig "claims" @()
    foreach ($claimConfig in $claims) {
        $claim = Get-OktaClaim -AuthorizationServerId $authServer.id -Query $claimConfig.name
        if ($claim) {
            Write-Information "Found '$($claimConfig.Name)' Claim"
        } else {
            $claim = New-OktaClaim -AuthorizationServerId $authServer.id `
                                    -Name $claimConfig.name `
                                    -ValueType $claimConfig.valueType `
                                    -ClaimType getProp $claim "claimType", "RESOURCE" `
                                    -Value $claimConfig.value `
                                    -Scopes getProp $claim "scopes" @()
            Write-Information "Added '$($claimConfig.Name)' Claim"
        }
    }

    $serverApps = getProp $authConfig "serverApplications" @()
    foreach ($newApp in $serverApps) {
        $appName = $newApp.name

        $app = Get-OktaApplication -Query $appName | Where-Object { $_.label -eq $appName }
        if ($app) {
            Write-Information "Found app '$appName'"
        } else {
            $app = New-OktaServerApplication -Label $appName -Properties (getProp $newApp "properties" $null) }
            Write-Information "Added app '$appName'"
        }

        # create policies to restrict scopes per app
        $policyName = getProd $newApp "policy" ""
        if ($policyName) {
            $policy = Get-OktaPolicy -AuthorizationServerId $authServer.id -Query $policyName
            if ($policy) {
                Write-Information "    Found '$($policyName)' Policy"
            } else {
                $policy = New-OktaPolicy -AuthorizationServerId $authServer.id `
                                         -Name $policyName `
                                         -ClientIds $app.Id
                Write-Information "    Added '$($policyName)' Policy"
            }
            $rule = Get-OktaRule -AuthorizationServerId $authServer.id -PolicyId $policy.id -Query "Allow $($policyName)"
            if ($rule) {
                Write-Information "    Found 'Allow $($policyName)' Rule"
                if (!(arraysEqual $rule.conditions.scopes.include $newApp.Scopes)) {
                    $rule.conditions.scopes.include = $newApp.Scopes
                    $null = Set-OktaRule -AuthorizationServerId $authServer.id -PolicyId $policy.id -Rule $rule
                    Write-Information "    Updated rule's scopes"
                }
            } else {
                $rule = New-OktaRule -AuthorizationServerId $authServer.id `
                                     -Name "Allow $($policyName)" `
                                     -PolicyId $policy.id `
                                     -Priority 1 `
                                     -GrantTypes client_credentials `
                                     -Scopes $newApp.Scopes
                Write-Information "    Added 'Allow $($policyName)' Rule"
            }
        }
    }

} catch {

}

}