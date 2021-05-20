# https://developer.okta.com/docs/reference/api/apps
Set-StrictMode -Version Latest

function Get-OktaApplication {
    [CmdletBinding(DefaultParameterSetName="Query")]
    param (
        [Parameter(ParameterSetName="ById",Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias("Id")]
        [Alias("ApplicationId")]
        [string] $AppId,
        [Parameter(ParameterSetName="Query",Position=0)]
        [string] $Query,
        [Parameter(ParameterSetName="Query")]
        [uint32] $Limit,
        [Parameter(ParameterSetName="Next")]
        [switch] $Next,
        [switch] $Json
    )

    process {
        if ($AppId) {
            Invoke-OktaApi -RelativeUri "apps/$AppId" -Json:$Json
        } else {
            Invoke-OktaApi -RelativeUri "apps$(Get-QueryParameters -Query $Query -Limit $Limit)" -Json:$Json -Next:$Next
        }
    }
}


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
                application_type = "service"
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
        [hashtable] $Properties,
        [ValidateRange(1,3)]
        [ValidateSet('Implicit','Code','Refresh')]
        [string[]] $GrantTypes = @('Implicit','Code')
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
                # if code, must include authorization_code
                response_types = @()
                grant_types = @()
                application_type = "browser"
                consent_method = "REQUIRED"
            }
        }
    }
    if ('Implicit' -in $GrantTypes) {
        $body.settings.oauthClient.response_types += "token","id_token"
        $body.settings.oauthClient.grant_types += 'implicit'
    }
    if ('Code' -in $GrantTypes) {
        $body.settings.oauthClient.response_types += "code"
        $body.settings.oauthClient.grant_types += 'authorization_code'
    }
    if ('Refresh' -in $GrantTypes) {
        $body.settings.oauthClient.response_types += "token","id_token"
        $body.settings.oauthClient.grant_types += 'refresh_token'
    }

    Add-PropertiesToObject -Object $body -Properties $Properties

    Invoke-OktaApi -RelativeUri "apps" -Body $body -Method POST
}

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
    Invoke-OktaApi -RelativeUri "apps/$($Application.Id)" -Method PUT -Body (ConvertTo-Json $Application -Depth 10)
}

function Remove-OktaApplication {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param(
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias("Id")]
        [string] $AppId
    )

    process {
        Set-StrictMode -Version Latest

        $app = Get-OktaApplication -AppId $AppId
        if ($app) {
            if ($PSCmdlet.ShouldProcess($app.Label,"Remove Application")) {
                Disable-OktaApplication -AppId $AppId
                Invoke-OktaApi -RelativeUri "apps/$AppId" -Method DELETE
            }
        } else {
            Write-Warning "Application with id '$AppId' not found"
        }
    }
}

function Disable-OktaApplication
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSShouldProcess", "")]
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [Alias("Id")]
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
        [Alias("Id")]
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
        [Alias("Id")]
        [Alias("ApplicationId")]
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

function Add-OktaApplicationUser {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSShouldProcess", "")]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [Alias("ApplicationId")]
        [string] $AppId,
        [Alias("Id")]
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [string] $UserId
    )

    process {
        Set-StrictMode -Version Latest

        Invoke-OktaApi -RelativeUri "apps/$AppId/users/$UserId" -Method PUT
    }
}
function Remove-OktaApplicationUser {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSShouldProcess", "")]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [Alias("ApplicationId")]
        [string] $AppId,
        [Alias("Id")]
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [string] $UserId
    )

    process {
        Set-StrictMode -Version Latest

        Invoke-OktaApi -RelativeUri "apps/$AppId/users/$UserId" -Method DELETE
    }
}


function Get-OktaApplicationGroup {
    [CmdletBinding(DefaultParameterSetName="Query")]
    param(
        [Parameter(Mandatory)]
        [Alias("ApplicationId")]
        [string] $AppId,
        [Parameter(ParameterSetName="ById",Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias('Id')]
        [string] $GroupId,
        [Parameter(ParameterSetName="Query",Position=0)]
        [uint32] $Limit,
        [Parameter(ParameterSetName="Next")]
        [switch] $Next,
        [switch] $Json
    )

    process {
        Set-StrictMode -Version Latest

        if ($GroupId) {
            Invoke-OktaApi -RelativeUri "apps/$AppId/groups/$GroupId" -Method GET -Json:$Json
        } else {
            Invoke-OktaApi -RelativeUri "apps/$AppId/groups$(Get-QueryParameters -Limit $Limit)" -Method GET -Json:$Json -Next:$Next
        }
    }
}


function Get-OktaApplicationUser {
    [CmdletBinding(DefaultParameterSetName="Query")]
    param(
        [Parameter(Mandatory)]
        [Alias("ApplicationId")]
        [string] $AppId,
        [Parameter(ParameterSetName="ById",Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias('Id')]
        [string] $UserId,
        [Parameter(ParameterSetName="Query",Position=0)]
        [string] $Query,
        [Parameter(ParameterSetName="Query")]
        [uint32] $Limit,
        [Parameter(ParameterSetName="Next")]
        [switch] $Next,
        [switch] $Json
    )

    process {
        Set-StrictMode -Version Latest

        if ($UserId) {
            Invoke-OktaApi -RelativeUri "apps/$AppId/users/$UserId" -Method GET -Json:$Json
        } else {
            Invoke-OktaApi -RelativeUri "apps/$AppId/users$(Get-QueryParameters -Query $Query -Limit $Limit)" -Method GET -Json:$Json -Next:$Next
        }
    }
}


function Remove-OktaApplicationGroup {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param(
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias('Id')]
        [Alias("ApplicationId")]
        [string] $AppId,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [string] $GroupId
    )

    process {
        Set-StrictMode -Version Latest

        if ($PSCmdlet.ShouldProcess("$AppId -= $GroupId","Remove Group from Application")) {
            Invoke-OktaApi -RelativeUri "apps/$AppId/groups/$GroupId" -Method DELETE
        }
    }
}
