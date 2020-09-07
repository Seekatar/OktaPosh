[CmdletBinding(SupportsShouldProcess)]
param()

# CCC naming conventions
# http://confluence.nix.cccis.com/display/IdAM/Entity+Naming+Conventions#EntityNamingConventions-Applications.1

# script to add Okta object for the Reliance project
if (!(Get-Module OktaPosh)) {
    Write-Warning "Must Import-Module OktaPosh and call Set-OktaOption before running this script."
    return
}
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

# what to set up
$authServerName = "Casualty-Reliance-AS"
$scopes = "access:token","get:item","save:item","remove:item"
$claimName = "appName"

$apps = @(
    @{ Name = "CCC-CASReliance-DRE"; Scopes = "get:item","access:token","save:item" },
    @{ Name = "CCC-CASReliance-Interface"; Scopes = "get:item","access:token","save:item" },
    @{ Name = "CCC-CASReliance-ThirdParty"; Scopes = "get:item","access:token" },
    @{ Name = "CICD-CASReliance-LoadTest-DEV"; Scopes = "get:item","access:token","save:item" }
)

$authServer = Get-OktaAuthorizationServer -Query $authServerName
if ($authServer) {
    "Found '$authServerName'"
} else {
    $authServer = New-OktaAuthorizationServer -Name $authServerName `
        -Audiences "api://cccis/reliance/api" `
        -Issuer "$(Get-OktaBaseUri)/oauth2/default" `
        -Description "Reliance Service Gateway Authorization Server"
    if ($authServer) {
        "Created '$authServerName'"
    } else {
        throw "Failed to create '$authServer'"
    }
}

$existingScopes = Get-OktaScope -AuthorizationServerId $authServer.id | Select-Object -ExpandProperty name
$scopes = $scopes | Where-Object { $_ -notin $existingScopes }
if ($scopes) {
    $null = $scopes | New-OktaScope -AuthorizationServerId $authServer.id
    "Scopes added: $($scopes -join ',')"
} else {
    "All scopes found"
}

# add appname claim to all scopes
$claim = Get-OktaClaim -AuthorizationServerId $authServer.id -Query $claimName
if ($claim) {
    "Found '$claimName' Claim"
} else {
    $claim = New-OktaClaim -AuthorizationServerId $authServer.id -Name $claimName -ValueType EXPRESSION -ClaimType RESOURCE -Value "app.profile.$claimName" -Scopes "access:token"
    "Added '$claimName' Claim"
}

foreach ( $newApp in $apps) {
    $appName = $newApp.Name

    $app = Get-OktaApplication -Query $appName
    if ($app) {
        "Found app '$appName'"
    } else {
        $app = New-OktaServerApplication -Label $appName -Properties @{appName = $appName }
        "Added app '$appName'"
    }

    # create policies to restrict scopes per app
    $policyName = "$($app.Label)-Policy"
    $policy = Get-OktaPolicy -AuthorizationServerId $authServer.id -Query $policyName
    if ($policy) {
        "    Found '$($policyName)' Policy"
    } else {
        $policy = New-OktaPolicy -AuthorizationServerId $authServer.id -Name $policyName -ClientIds $app.Id
        "    Added '$($policyName)' Policy"
    }
    $rule = Get-OktaRule -AuthorizationServerId $authServer.id -PolicyId $policy.id -Query "Allow $($policyName)"
    if ($rule) {
        "    Found 'Allow $($policyName)' Rule"
    } else {
        $rule = New-OktaRule -AuthorizationServerId $authServer.id -Name "Allow $($policyName)" -PolicyId $policy.id -Priority 1 `
                 -GrantTypes client_credentials -Scopes $newApp.Scopes
        "    Added 'Allow $($policyName)' Rule"
    }
}
