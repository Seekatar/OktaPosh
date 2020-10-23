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
        [uint32] $Limit,
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

    # settings for OAUTH https://developer.okta.com/docs/reference/api/apps/#add-oauth-2-0-client-application
    $body = [PSCustomObject]@{
        name      = $Name
        status    = ternary $Inactive "INACTIVE" "ACTIVE"
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
                application_type = "service" #z browser for UI
            }
        }
    }

    Add-PropertiesToObject -Object $body -Properties $Properties

    Invoke-OktaApi -RelativeUri "apps" -Body $body -Method POST
}

function New-OktaSpaApplication {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSShouldProcess", "")]
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [string] $Label,
        [Parameter(Mandatory)]
        [string[]] $RedirectUris,
        [Parameter(Mandatory)]
        [string] $LoginUri,
        [string[]] $PostLogoutUris,
        [switch] $Inactive,
        [string] $SignOnMode = "OPENID_CONNECT",
        [hashtable] $Properties
    )

    $Name = "oidc_client" # https://developer.okta.com/docs/reference/api/apps/#app-names-and-settings

    # settings for OAUTH https://developer.okta.com/docs/reference/api/apps/#add-oauth-2-0-client-application
    $body = [PSCustomObject]@{
        name      = $Name
        status    = ternary $Inactive "INACTIVE" "ACTIVE"
        label     = $Label
        signOnMode = $SignOnMode
        credentials = @{
            oauthClient = @{
              autoKeyRotation = $true
              token_endpoint_auth_method = "none"
            }
        }
        settings   = @{
            oauthClient = @{
                issuer_mode = "ORG_URL"
                redirect_uris = $RedirectUris
                post_logout_redirect_uris = $PostLogoutUris
                initiate_login_uri = $LoginUri
                response_types = @(
                    "token","id_token"
                )
                grant_types = @(
                    "implicit"
                )
                application_type = "browser"
                consent_method = "REQUIRED"
            }
        }
    }

    Add-PropertiesToObject -Object $body -Propertied $Properties

    Invoke-OktaApi -RelativeUri "apps" -Body $body -Method POST
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
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSShouldProcess", "")]
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [PSCustomObject] $Application,
        [Parameter(Mandatory)]
        [hashtable] $Properties
    )

    Add-PropertiesToObject -Object $Application -Properties $Properties
    Invoke-OktaApi -RelativeUri "apps/$($App.Id)" -Method PUT -Body (ConvertTo-Json $Application -Depth 10)
}

<#
.SYNOPSIS
Delete an application

.PARAMETER AppId
Id of the application
#>
function Remove-OktaApplication {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param(
        [Parameter(Mandatory,ValueFromPipeline)]
        [Alias('Id')]
        [string] $AppId
    )

    process {
        Set-StrictMode -Version Latest

        $app = Get-OktaApplication -AppId $AppId
        if ($app) {
            if ($PSCmdlet.ShouldProcess("'$($app.Label)' Id=$AppId","Remove Application")) {
                Disable-OktaApplication -AppId $AppId
                Invoke-OktaApi -RelativeUri "apps/$AppId" -Method DELETE
            }
        } else {
            Write-Host "Application with id '$AppId' not found"
        }
    }
}

function Disable-OktaApplication
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSShouldProcess", "")]
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [Alias('Id')]
        [string] $AppId
    )
    Invoke-OktaApi -RelativeUri "apps/$AppId/lifecycle/deactivate" -Method POST
}

function Enable-OktaApplication
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSShouldProcess", "")]
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [Alias('Id')]
        [string] $AppId
    )
    Invoke-OktaApi -RelativeUri "apps/$AppId/lifecycle/activate" -Method POST
}

function Set-OktaApplication {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [PSCustomObject] $Application
    )

    if ($PSCmdlet.ShouldProcess("$($Application.label)","Update Application")) {
        Invoke-OktaApi -RelativeUri "apps/$($Application.id)" -Body $Application -Method PUT
    }
}

function Add-OktaApplicationGroup {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [Alias('Id')]
        [string] $AppId,
        [Parameter(Mandatory,ValueFromPipeline)]
        [string] $GroupId,
        [ValidateRange(0,100)]
        [int] $Priority = 0,
        [hashtable] $Properties
    )

    process {
        Set-StrictMode -Version Latest

        $props = [PSCustomObject]@{
            priority = $Priority
        }
        Add-PropertiesToObject -Object $props -Properties $Properties
        if ($PSCmdlet.ShouldProcess("$AppId += $GroupId","Add Group to Application")) {
            Invoke-OktaApi -RelativeUri "apps/$AppId/groups/$groupId" -Method PUT -Body $props
        }
    }
}

function Get-OktaApplicationGroup {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $AppId,
        [Parameter(Mandatory,ValueFromPipeline,ParameterSetName="ById")]
        [Alias('Id')]
        [string] $GroupId,
        [Parameter(ParameterSetName="Query")]
        [uint32] $Limit,
        [Parameter(ParameterSetName="Query")]
        [string] $After
    )

    process {
        Set-StrictMode -Version Latest

        if ($GroupId) {
            Invoke-OktaApi -RelativeUri "apps/$AppId/groups/$GroupId" -Method GET
        } else {
            Invoke-OktaApi -RelativeUri "apps/$AppId/groups$(Get-QueryParameters -Limit $Limit -After $After)" -Method GET
        }
    }
}


function Get-OktaApplicationUser {
    [CmdletBinding(DefaultParameterSetName="Query")]
    param(
        [Parameter(Mandatory)]
        [string] $AppId,
        [Parameter(Mandatory,ValueFromPipeline,ParameterSetName="ById")]
        [Alias('Id')]
        [string] $UserId,
        [Parameter(ParameterSetName="Query")]
        [string] $Query,
        [Parameter(ParameterSetName="Query")]
        [uint32] $Limit,
        [Parameter(ParameterSetName="Query")]
        [string] $After
    )

    process {
        Set-StrictMode -Version Latest

        if ($UserId) {
            Invoke-OktaApi -RelativeUri "apps/$AppId/users/$UserId" -Method GET
        } else {
            Invoke-OktaApi -RelativeUri "apps/$AppId/users$(Get-QueryParameters -Query $Query -Limit $Limit -After $After)" -Method GET
        }
    }
}


function Remove-OktaApplicationGroup {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param(
        [Parameter(Mandatory,ValueFromPipeline)]
        [Alias('Id')]
        [string] $AppId,
        [Parameter(Mandatory,ValueFromPipeline)]
        [string] $GroupId
    )

    process {
        Set-StrictMode -Version Latest

        if ($PSCmdlet.ShouldProcess("$AppId -= $GroupId","Remove Group from Application")) {
            Invoke-OktaApi -RelativeUri "apps/$AppId/groups/$GroupId" -Method DELETE
        }
    }
}

if (!(Test-Path alias:goktaapp)) {
    New-Alias goktaapp Get-OktaApplication
}

