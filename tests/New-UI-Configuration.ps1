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
$authServerName = "Casualty-Reliance-RBR-AS"
# currently UI asks for last 3, and need openid
$scopes = "fpui:read","fpui:write","fpui:delete","openid","profile","email"

# 'X-CCC-FP-Email': email,
# 'X-CCC-FP-Username': email,
# 'X-CCC-FP-UserId': '1',
# 'X-CCC-FP-ClientCode': 'INS1',
# 'X-CCC-FP-ProfileId': '1',
# 'X-CCC-FP-Roles': 'admin', = memberOf // role in appuser for appusername or appuserrole $appuser.attributename (app is name, not label)
# 'X-CCC-FP-PictureUrl': 'TODO',
# also have app properties $app.attribute
# also have org properties org.
# groups?getFilteredGroups

$claims = @(
    @{
        name = "roles"
        valueType = "GROUPS"
        value = "CCC-Reliance-RBR-"
        claimType= "RESOURCE"
    },
    @{
        name = "clients"
        valueType = "GROUPS"
        value = "CCC-Reliance-Client-"
        claimType= "RESOURCE"
    },
    @{
        name = "profileUrl"
        valueType = "EXPRESSION"
        value = "appuser.profile"
        claimType= "RESOURCE"
    },
    @{
        name = "email"
        valueType = "EXPRESSION"
        value = "appuser.email"
        claimType= "RESOURCE"
    },
    @{
        name = "friendlyName"
        valueType = "EXPRESSION"
        value = "String.len(appuser.name) > 0 ? appuser.name : appuser.given_name+ `" `" + appuser.family_name"
        claimType= "RESOURCE"
    },
    @{
        name = "login"
        valueType = "EXPRESSION"
        value = "appuser.email"
        claimType= "RESOURCE"
    },
    @{
        name = "pictureUrl"
        valueType = "EXPRESSION"
        value = "appuser.picture"
        claimType= "RESOURCE"
    },
    @{
        name = "profileUrl"
        valueType = "EXPRESSION"
        value = "appuser.profile"
        claimType= "RESOURCE"
    }
)

$audience = "https://reliance-qa/fp-ui"
$description = "Reliance First-Party UI"
$apps = @(
    @{ Name = "Casualty-Reliance-RBR"
    RedirectUris = @(
        "https://1085090-devrmq01.reprice.nhr.com:31100/fp-ui/implicit/callback",
        "https://reliance-dev.reprice.nhr.com/fp-ui/implicit/callback",
        "http://localhost:8080/fp-ui/implicit/callback"
    )
    LoginUri = "https://reliance-dev.reprice.nhr.com/fp-ui/"
    PostLogoutUris = "https://reliance-dev.reprice.nhr.com/fp-ui/"
    Scopes = $scopes }
)
$groupNames = @("CCC-Reliance-RBR-Group",
                "RelianceDevs",
                "RelianceQA",
                "RelianceUsers")

$origins = @("https://reliance-dev.reprice.nhr.com")

try {

    . (Join-Path $PSScriptRoot New-OktaAuthServerConfig.ps1)
    . (Join-Path $PSScriptRoot New-OktaAppConfig.ps1)
    $uri = New-Object 'System.Uri' -ArgumentList (Get-OktaBaseUri)
    $issuer = "$($uri.Scheme)://$($uri.Host)"
    "Issuer is $issuer"

    $authServer = New-OktaAuthServerConfig -authServerName $authServerName `
                            -Scopes $scopes `
                            -audience $audience `
                            -description $description `
                            -issuer $issuer `
                            -claims $claims

    $groups = @()
    foreach ($group in $groupNames) {
        $g = Get-OktaGroup -Query $group
        if ($g) {
            Write-Host "Found group $group"
        } else {
            $g = New-OktaGroup -Name $group
            Write-Host "Added group $group"
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
            Write-Host "    Added $($group.profile.name) group to app $($app.label)"
        }
    }

    foreach ($origin in $origins) {
        if (Get-OktaTrustedOrigin -Filter "origin eq `"$origin`"") {
            Write-Host "Found origin $origin"
        } else {
            $null = New-OktaTrustedOrigin -Name $origin -Origin $origin -CORS -Redirect
            Write-Host "Added origin $origin"
        }
     }

} catch {
    Write-Error "$_`n$($_.ScriptStackTrace)"
}