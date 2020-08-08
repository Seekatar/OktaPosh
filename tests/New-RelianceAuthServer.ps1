Import-Module .\OktaPosh.psm1 -fo -ArgumentList $true
Set-OktaOptions
$ErrorActionPreference = "Stop"

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
$scopes | Where-Object { $_ -notin $existingScopes } | New-OktaScope -AuthorizationServerId $authServer.id

$claims = @(
    [PSCustomObject] @{Name = "appName";ValueType="EXPRESSION";ClaimType="RESOURCE";Value="app.profile.appName"}
)

$existingClaims = Find-OktaClaim -AuthorizationServerId $authServer.id -Query "appName"
if (!$existingClaims) {
    $claims | New-OktaClaim -AuthorizationServerId $authServer.id
    "Added claims $($claims.Name -join ',')"
}

$dreApp = Find-OktaApplication -Query DRE
if ($dreApp) {

}
$interfaceApp = Find-OktaApplication -Query InterfaceService
if ($interfaceApp) {

}
$label = "CausualtyThirdParty"
$thirdParty = Find-OktaApplication -Query $label
if (!$thirdParty) {
    $thirdParty = New-OktaApplication -Label $label -Properties @{appName = $label }
}

# add appname claim to all scopes
$claim = New-OktaClaim -AuthorizationServerId $authServer.id -Name appName -ValueType EXPRESSION -ClaimType RESOURCE -Value "app.profile.appName"

# create policies to restrict scopes per app
$apps = $dreApp, $interfaceApp, $thirdParty
foreach ( $app in $apps) {
    $policy = New-OktaPolicy -AuthorizationServerId $authServer.id -Name $app.Label -ClientIds $app.Id
    $scopes = "get_item","access_token"
    if ($label -ne "CasualtyThirdParty") {
        $scopes += "save_item"
    }
    New-OktaRule -AuthorizationServerId $authServer.id -Name "Allow $($app.Label)" -PolicyId $policy.id -Priority 1 `
                 -GrantTypes client_credentials -Scopes $scopes
}
