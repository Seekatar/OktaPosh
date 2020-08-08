# script to add Okta object for the Reliance project
if (!$env:OktaApiToken -or ! $env:OktaBaseUri) {
    Write-Warning "`$env:OktaApiToken and `$env:OktaBaseUri must be set"
    return
}
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

Import-Module (Join-Path $PSScriptRoot ../src/OktaPosh.psm1) -fo -ArgumentList $true
Set-OktaOptions

# what to set up
$authServerName = "RelianceGatewayAPI"
$scopes = "access_token","get_item","save_item","remove_item"


$authServer = Find-OktaAuthorizationServer -Query $authServerName
if ($authServer) {
    "Found $authServerName"
} else {
    $authServer = New-OktaAuthorizationServer -Name $authServerName `
        -Audience "api://cccis/reliance/api" `
        -Issuer "$(Get-OktaBaseUri)/oauth2/default" `
        -Description "Reliance API Server"
    if ($authServer) {
        "Created $authServerName"
    } else {
        throw "Failed to create $authServer"
    }
}

$existingScopes = Find-OktaScope -AuthorizationServerId $authServer.id | Select-Object -ExpandProperty name
$scopes = $scopes | Where-Object { $_ -notin $existingScopes }
if ($scopes) {
    $scopes | New-OktaScope -AuthorizationServerId $authServer.id
    "Scopes added: $($scopes -join ',')"
} else {
    "All scopes found"
}

# add appname claim to all scopes
$claim = Find-OktaClaim -AuthorizationServerId $authServer.id -Query appName
if ($claim) {
    "Found appName Claim"
} else {
    $claim = New-OktaClaim -AuthorizationServerId $authServer.id -Name appName -ValueType EXPRESSION -ClaimType RESOURCE -Value "app.profile.appName"
    "Added appName Claim"
}

$appNames = "DREApp", "InterfaceApp", "ThirdPartyApp"
foreach ( $app in $appNames) {

    $app = Find-OktaApplication -Query $_
    if ($app) {
        "Found app $_"
    } else {
        $app = New-OktaApplication -Label $_ -Properties @{appName = $_ }
        "Added app $_"
    }

    # create policies to restrict scopes per app
    $policy = Find-OktaPolicy -AuthorizationServerId $authServer.id -Query $app.Label
    if ($policy) {
        "    Found $($app.Label) policy"
    } else {
        $policy = New-OktaPolicy -AuthorizationServerId $authServer.id -Name $app.Label -ClientIds $app.Id
        $scopes = "get_item","access_token"
        if ($label -ne "CasualtyThirdParty") {
            $scopes += "save_item"
        }
    }
    $rule = Find-OktaRule -AuthorizationServerId $authServer.id -PolicyId $policy.id -Query "Allow $($app.Label)"
    if ($rule) {
        "    Found rule 'Allow $($app.Label)'"
    } else {
        $rule = New-OktaRule -AuthorizationServerId $authServer.id -Name "Allow $($app.Label)" -PolicyId $policy.id -Priority 1 `
                 -GrantTypes client_credentials -Scopes $scopes
    }
}
