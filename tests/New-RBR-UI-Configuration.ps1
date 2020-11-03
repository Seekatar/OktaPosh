[CmdletBinding(SupportsShouldProcess)]
param(
    [ValidateSet("dev","qa","uat","ct","int","prod")]
    [string] $Environment = "dev",
    [switch] $DataCapture
)
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# CCC naming conventions
# http://confluence.nix.cccis.com/display/IdAM/Entity+Naming+Conventions#EntityNamingConventions-Applications.1

$domainSuffix = ""
if ($Environment -ne 'prod') {
    $domainSuffix = "-$Environment"
}

$name = "RBR"
$uiPath = "fp-ui"
if ($DataCapture) {
    $name = "DataCapture"
    $uiPath = "dc-ui"
}
$nameLower = $name.ToLowerInvariant()

# script to add Okta object for the Reliance project
if (!(Get-Module OktaPosh)) {
    Write-Warning "Must Import-Module OktaPosh and call Set-OktaOption before running this script."
    return
}

# AuthorizationServer configuration
$authServerName = "Casualty-$name-AS"
$scopes = @("casualty.$nameLower.client.usaa",
            "casualty.$nameLower.client.den1",
            "casualty.$nameLower.client.safeco",
            "casualty.$nameLower.client.ins1", # this is junk test one
            "casualty.$nameLower.client.nw")

$claims = @(
    @{
        name = "roles"
        valueType = "GROUPS"
        groupFilterType = "STARTS_WITH"
        value = "CCC-$name-Role-"
        claimType= "ACCESS_TOKEN"
    },
    @{
        name = "clients"
        valueType = "GROUPS"
        groupFilterType = "STARTS_WITH"
        value = "CCC-$name-Client-"
        claimType= "ACCESS_TOKEN"
    },
    @{
        name = "email"
        valueType = "EXPRESSION"
        value = "user.email"
        claimType= "ACCESS_TOKEN"
    },
    @{
        name = "friendlyName"
        valueType = "EXPRESSION"
        value = 'String.len(user.displayName) > 0 ? user.displayName : user.firstName+ " " + user.lastName'
        claimType= "ACCESS_TOKEN"
    },
    @{
        name = "friendlyName"
        valueType = "EXPRESSION"
        value = 'String.len(user.displayName) > 0 ? user.displayName : user.firstName+ " " + user.lastName'
        claimType= "ID_TOKEN"
    },
    @{
        name = "login"
        valueType = "EXPRESSION"
        value = "user.email"
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
        value = "user.profileUrl"
        claimType= "ID_TOKEN"
    }
)

# Application Configuration
$audience = "https://reliance/$uiPath"
$description = "$name UI for casualty"
$apps = @(
    @{ Name = "CCC-CAS$name-SPA"
       RedirectUris = @(
        "https://reliance$domainSuffix.reprice.nhr.com/$uiPath/implicit/callback",
        "http://localhost:8080/$uiPath/implicit/callback"
        )
       LoginUri = "https://reliance$domainSuffix.reprice.nhr.com/$uiPath/"
       PostLogoutUris = "https://reliance$domainSuffix.reprice.nhr.com/$uiPath/"
       Scopes = $scopes + "openid","profile","email"
    }
)

# Groups
$groupNames = @("CCC-$name-Client-USAA-Group",
                "CCC-$name-Client-NW-Group",
                "CCC-$name-Client-INS1-Group",
                "CCC-$name-Client-GEICO-Group")

# Origin
$origins = @("https://reliance$domainSuffix.reprice.nhr.com")

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