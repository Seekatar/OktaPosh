# https://developer.okta.com/docs/reference/api/apps/#application-properties

Set-StrictMode -Version Latest

function Get-OktaApplication {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $AppId,
        [switch] $RawContent
    )

    Invoke-OktaApi -RelativeUri "apps/$AppId" -RawContent:$RawContent
}
function Find-OktaApplication {
    [CmdletBinding()]
    param (
        [string] $Query,
        [uint] $Limit,
        [string] $After
    )

    Invoke-OktaApi -RelativeUri "apps$(Get-QueryParameters $Query $Limit $After)"
}

function New-OktaApplication {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [string] $Label,
        [string] $Name = "oidc_client", # https://developer.okta.com/docs/reference/api/apps/#app-names-and-settings
        [switch] $Inactive,
        [string] $SignOnMode = "OPENID_CONNECT",
        [hashtable] $Properties
    )

    $body = [PSCustomObject]@{
        name      = $Name
        status    = $Inactive ? "INACTIVE" : "ACTIVE"
        label     = $Label
        signOnMode = $SignOnMode
        settings   = @{
            oauthClient = @{
                issuer_mode = "ORG_URL"
                response_types = @(
                    "token"
                )
                grant_types = @(
                    "client_credentials"
                )
                application_type = "service"
            }
        }
    }

    Add-PropertiesToApp $body $Properties

    Invoke-OktaApi -RelativeUri "apps" -Body (ConvertTo-Json $body -Depth 10) -Method POST
}

function Add-PropertiesToApp {
    param (
        [Parameter(Mandatory)]
        [PSCustomObject] $Application,
        [hashtable] $Properties
    )

    if ($Properties) {
        if (!(Get-Member -InputObject $Application -Name 'profile')) {
            Add-Member -InputObject $Application -MemberType NoteProperty -Name 'profile' -Value $Properties
        }
        else {
            foreach ($p in $Properties.Keys) {
                if (!(Get-Member -InputObject $Application.profile -Name $p)) {
                    Add-Member -InputObject $Application.profile -MemberType NoteProperty -Name $p -Value $Properties[$p]
                } else {
                    $Application.profile.$p = $Properties[$p]
                }
            }
        }
    }
}

<#
.SYNOPSIS
Set an application property

.DESCRIPTION
This will set a property on the application that can be used in a Claim with an Expression of app.profile.<name>

.PARAMETER App
Application object retrieved from Get-OktaApplication

.PARAMETER Properties
Hashtable of properties and the values to set on the Application

.EXAMPLE
$app = Get-OktaApplcation $appId
Set-OktaApplicationProperty -Application $app -Properties @{client_id = "INS1", client_profile_id = 1234 }

Set client_id and client_profile_id on the app

.NOTES
General notes
#>
function Set-OktaApplicationProperty {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [PSCustomObject] $Application,
        [Parameter(Mandatory)]
        [hashtable] $Properties
    )

    Add-PropertiesToApp $Application $Properties
    Invoke-OktaApi -RelativeUri "apps/$($App.Id)" -Method PUT -Body (ConvertTo-Json $Application -Depth 10)
}

