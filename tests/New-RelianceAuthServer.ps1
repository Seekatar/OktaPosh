# script to add Okta object for the Reliance project
if (!$env:OktaApiToken -or ! $env:OktaBaseUri) {
    Write-Warning "`$env:OktaApiToken and `$env:OktaBaseUri must be set"
    return
}
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

# what to set up
$authServerName = "RelianceGatewayAPI"
$scopes = "access_token","get_item","save_item","remove_item"
$claimName = "appName"

$apps = @(
    @{ Name = "DREApp"; $Scopes = "get_item","access_token","save_item" },
    @{ Name = "InterfaceApp"; $Scopes = "get_item","access_token","save_item" },
    @{ Name = "ThirdPartyApp"; $Scopes = "get_item","access_token","save_item" }
)


Import-Module (Join-Path $PSScriptRoot ../src/OktaPosh.psm1) -fo -ArgumentList $true
Set-OktaOption

$authServer = Get-OktaAuthorizationServer -Query $authServerName
if ($authServer) {
    "Found '$authServerName'"
} else {
    $authServer = New-OktaAuthorizationServer -Name $authServerName `
        -Audience "api://cccis/reliance/api" `
        -Issuer "$(Get-OktaBaseUri)/oauth2/default" `
        -Description "Reliance API Server"
    if ($authServer) {
        "Created '$authServerName'"
    } else {
        throw "Failed to create '$authServer'"
    }
}

$existingScopes = Get-OktaScope -AuthorizationServerId $authServer.id | Select-Object -ExpandProperty name
$scopes = $scopes | Where-Object { $_ -notin $existingScopes }
if ($scopes) {
    $scopes | New-OktaScope -AuthorizationServerId $authServer.id
    "Scopes added: $($scopes -join ',')"
} else {
    "All scopes found"
}

# add appname claim to all scopes
$claim = Get-OktaClaim -AuthorizationServerId $authServer.id -Query $claimName
if ($claim) {
    "Found '$claimName' Claim"
} else {
    $claim = New-OktaClaim -AuthorizationServerId $authServer.id -Name $claimName -ValueType EXPRESSION -ClaimType RESOURCE -Value "app.profile.$claimName" -Scopes "access_token"
    "Added '$claimName' Claim"
}

foreach ( $newApp in $apps) {
    $appName = $newApp.Name

    $app = Get-OktaApplication -Query $appName
    if ($app) {
        "Found app '$appName'"
    } else {
        $app = New-OktaServerApplication -Label $app -Properties @{appName = $appName }
        "Added app '$appName'"
    }

    # create policies to restrict scopes per app
    $policy = Get-OktaPolicy -AuthorizationServerId $authServer.id -Query $app.Label
    if ($policy) {
        "    Found '$($app.Label)' Policy"
    } else {
        $policy = New-OktaPolicy -AuthorizationServerId $authServer.id -Name $app.Label -ClientIds $app.Id
        "    Added '$($app.Label)' Policy"
    }
    $rule = Get-OktaRule -AuthorizationServerId $authServer.id -PolicyId $policy.id -Query "Allow $($app.Label)"
    if ($rule) {
        "    Found 'Allow $($app.Label)' Rule"
    } else {
        $rule = New-OktaRule -AuthorizationServerId $authServer.id -Name "Allow $($app.Label)" -PolicyId $policy.id -Priority 1 `
                 -GrantTypes client_credentials -Scopes $newApp.Scopes
        "    Added 'Allow $($app.Label)' Rule"
    }
}
