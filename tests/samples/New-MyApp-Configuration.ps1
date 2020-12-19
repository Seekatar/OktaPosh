[CmdletBinding(SupportsShouldProcess)]
param(
    [ValidateSet("dev","qa","uat","ct","int","prod")]
    [string] $Environment
)
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$domainSuffix = ""
if ($Environment -ne 'prod') {
    $domainSuffix = "-$Environment"
}

$name = "Tets"
$uiPath = "fp-ui"
$nameLower = $name.ToLowerInvariant()

# script to add Okta object for the Myapp project
if (!(Get-Module OktaPosh)) {
    Write-Warning "Must Import-Module OktaPosh and call Set-OktaOption before running this script."
    return
}

$AuthServer = @{
    authServerName = "Casualty-$name-AS"
    audience = "https://myapp/$uiPath"
    description = "$name UI for casualty"
    scopes = @("casualty.$nameLower.client.usaa",
                "casualty.$nameLower.client.den1",
                "casualty.$nameLower.client.safeco",
                "casualty.$nameLower.client.ins1", # this is junk test one
                "casualty.$nameLower.client.nw")

    claims = @(
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
}

$Applications = @(
        @{ Name = "CCC-CAS$name-SPA"
            RedirectUris = @(
            "https://myapp$domainSuffix.test.com/$uiPath/implicit/callback",
            "http://localhost:8080/$uiPath/implicit/callback"
            )
            LoginUri = "https://myapp$domainSuffix.test.com/$uiPath/"
            PostLogoutUris = "https://myapp$domainSuffix.test.com/$uiPath/"
            Scopes = '*'
        }
    )

$GroupNames = @("CCC-$name-Client-Client1-Group",
                 "CCC-$name-ClientClient2-Group",
                 "CCC-$name-ClientClient3-Group",
                 "CCC-$name-ClientClient4-Group"
                 )

$Origins = @("https://myapp$domainSuffix.test.com")

. (Join-Path $PSScriptRoot New-OktaAppAndAuthServerConfig.ps1)

New-OktaAppAndAuthServerConfig -AuthServer $AuthServer -Applications $Applications -GroupNames $GroupNames -Origins $Origins

