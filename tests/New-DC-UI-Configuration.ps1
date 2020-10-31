[CmdletBinding(SupportsShouldProcess)]
param(
    [string] $Environment = "dev"
)

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
$authServerName = "Casualty-DataCapture-AS"
$scopes = @("casualty.datacapture.client.usaa",
            "casualty.datacapture.client.geico",
            "casualty.datacapture.client.nw")

$claims = @(
    @{
        name = "roles"
        valueType = "GROUPS"
        groupFilterType = "STARTS_WITH"
        value = "CCC-DataCapture-Role-"
        claimType= "ACCESS_TOKEN"
    },
    @{
        name = "clients"
        valueType = "GROUPS"
        groupFilterType = "STARTS_WITH"
        value = "CCC-DataCapture-Client-"
        claimType= "ACCESS_TOKEN"
    },
    @{
        name = "email"
        valueType = "EXPRESSION"
        value = "appuser.email"
        claimType= "ACCESS_TOKEN"
    },
    @{
        name = "friendlyName"
        valueType = "EXPRESSION"
        value = "String.len(appuser.name) > 0 ? appuser.name : appuser.given_name+ `" `" + appuser.family_name"
        claimType= "ACCESS_TOKEN"
    },
    @{
        name = "login"
        valueType = "EXPRESSION"
        value = "appuser.email"
        claimType= "ACCESS_TOKEN"
    },
    @{
        name = "pictureUrl"
        valueType = "EXPRESSION"
        value = "appuser.picture"
        claimType= "ID_TOKEN"
    },
    @{
        name = "profileUrl"
        valueType = "EXPRESSION"
        value = "appuser.profile"
        claimType= "ID_TOKEN"
    }
)

$audience = "https://reliance/dc-ui"
$description = "DataCapture UI"
$apps = @(
    @{ Name = "CCC-DataCapture-SPA"
    RedirectUris = @(
        "https://reliance-$environment.reprice.nhr.com/dc-ui/implicit/callback",
        "http://localhost:8080/dc-ui/implicit/callback"
    )
    LoginUri = "https://reliance-$environment.reprice.nhr.com/dc-ui/"
    PostLogoutUris = "https://reliance-$environment.reprice.nhr.com/dc-ui/"
    Scopes = $scopes + "openid","profile","email" }
)
$groupNames = @("CCC-DataCapture-Client-USAA-Group",
                "CCC-DataCapture-Client-NW-Group",
                "CCC-DataCapture-Client-GEICO-Group")

$origins = @("https://reliance-$environment.reprice.nhr.com")

try {

    . (Join-Path $PSScriptRoot New-OktaAuthServerConfig.ps1)
    . (Join-Path $PSScriptRoot New-OktaAppConfig.ps1)

    $authServer = New-OktaAuthServerConfig -authServerName $authServerName `
                            -Scopes $scopes `
                            -audience $audience `
                            -description $description `
                            -claims $claims

    $groups = @()
    foreach ($group in $groupNames) {
        $g = Get-OktaGroup -Query $group
        if ($g) {
            Write-Host "Found group '$group'"
        } else {
            $g = New-OktaGroup -Name $group
            Write-Host "Added group '$group'"
        }
        $groups += $g
    }

    foreach ($newApp in $apps) {
        $app = New-OktaAppConfig -Name $newApp.Name `
                        -Scopes $newApp.Scopes `
                        -RedirectUris $newApp.RedirectUris `
                        -LoginUri $newApp.LoginUri `
                        -PostLogoutUris $newApp.PostLogoutUris `
                        -GrantTypes "authorization_code", "password", "client_credentials", "implicit" `
                        -AuthServerId $authServer.Id
        foreach ($group in $groups) {
            $null = Add-OktaApplicationGroup -AppId $app.id -GroupId $group.id
            Write-Host "    Added '$($group.profile.name)' group to app '$($app.label)'"
        }
    }

    foreach ($origin in $origins) {
        if (Get-OktaTrustedOrigin -Filter "origin eq `"$origin`"") {
            Write-Host "Found origin '$origin'"
        } else {
            $null = New-OktaTrustedOrigin -Name $origin -Origin $origin -CORS -Redirect
            Write-Host "Added origin '$origin'"
        }
     }

} catch {
    Write-Error "$_`n$($_.ScriptStackTrace)"
}