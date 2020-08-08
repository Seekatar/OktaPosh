Set-StrictMode -Version Latest
# https://developer.okta.com/docs/reference/api/apps/#application-properties

<#
.SYNOPSIS
Get one or more Okta Applications

.DESCRIPTION


.PARAMETER AppId
Application id to get.

.PARAMETER Query
Query for name and label search

.PARAMETER Limit
Limit the number to return

.PARAMETER After
After value returned in the link, if more results

.EXAMPLE
Get-OktaApplication -Query "MyApp"

#>
function Get-OktaApplication {
    [CmdletBinding(DefaultParameterSetName="Query")]
    param (
        [Parameter(Mandatory,ParameterSetName="ById",ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias("id")]
        [string] $AppId,
        [Parameter(ParameterSetName="Query")]
        [string] $Query,
        [Parameter(ParameterSetName="Query")]
        [uint] $Limit,
        [Parameter(ParameterSetName="Query")]
        [string] $After
    )

    process {
        if ($AppId) {
            Invoke-OktaApi -RelativeUri "apps/$AppId"
        } else {
            Invoke-OktaApi -RelativeUri "apps$(Get-QueryParameters $Query $Limit $After)"
        }
    }
}

<#
.SYNOPSIS
Create a new server-type OAuth Application

.DESCRIPTION
Long description

.PARAMETER Label
Friendly name for the application

.PARAMETER Inactive
Set to create inactive

.PARAMETER SignOnMode
Defaults to OPENID_CONNECT

.PARAMETER Properties
Additional properties to use in app.profile.<name> claims for the app

.EXAMPLE
$app = New-OktaServerApplication -Label MyApp -Properties @{appName = "MyApp" }

Create a server with an appName property
#>
function New-OktaServerApplication {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSShouldProcess", "")]
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [string] $Label,
        [switch] $Inactive,
        [string] $SignOnMode = "OPENID_CONNECT",
        [hashtable] $Properties
    )

    $Name = "oidc_client" # https://developer.okta.com/docs/reference/api/apps/#app-names-and-settings

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

