# https://developer.okta.com/docs/reference/api/authorization-servers/
Set-StrictMode -Version Latest

function Get-OktaAuthorizationServer
{
    [CmdletBinding(DefaultParameterSetName="Query")]
    param (
        [Parameter(Mandatory,ParameterSetName="ById",ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias("Id")]
        [string] $AuthorizationServerId,
        [Parameter(ParameterSetName="Query")]
        [string] $Query,
        [Parameter(ParameterSetName="Query")]
        [uint32] $Limit,
        [Parameter(ParameterSetName="Next")]
        [switch] $Next,
        [switch] $Json
    )

    process {
        if ($AuthorizationServerId) {
            Invoke-OktaApi -RelativeUri "authorizationServers/$AuthorizationServerId" -Json:$Json
        } else {
            Invoke-OktaApi -RelativeUri "authorizationServers$(Get-QueryParameters -Query $Query -Limit $Limit)" -Json:$Json -Next:$Next
        }
    }
}

function Get-OktaOpenIdConfig {
    param (
        [Parameter(Mandatory,ParameterSetName="ById",ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias("Id")]
        [string] $AuthorizationServerId
    )

    process {
        Invoke-RestMethod "$(Get-OktaBaseUri)/oauth2/$AuthorizationServerId/.well-known/openid-configuration"
    }
}


function New-OktaAuthorizationServer
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSShouldProcess", "")]
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [string] $Name,
        [Parameter(Mandatory)]
        [string[]] $Audiences,
        [string] $Description
    )

    $body = @{
        name        = $Name
        description = (ternary [bool]$Description $Description "Added by OktaPosh")
        audiences   = @($Audiences)
    }
    Invoke-OktaApi -RelativeUri "authorizationServers" -Method POST -Body $body
}

function Set-OktaAuthorizationServer
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSShouldProcess", "")]
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [Alias('Id')]
        [string] $AuthorizationServerId,
        [Parameter(Mandatory)]
        [string] $Name,
        [Parameter(Mandatory)]
        [string[]] $Audiences,
        [ValidateSet("ORG_URL","CUSTOM_URL_DOMAIN")]
        [string] $IssuerMode = "ORG_URL",
        [string] $Description
    )

    if (!$Description)
    {
        $Description = $Name
    }

    $body = @{
        name        = $Name
        description = $Description
        audiences   = @($Audiences)
        issuerMode  = $IssuerMode
    }
    Invoke-OktaApi -RelativeUri "authorizationServers/$AuthorizationServerId" -Method PUT -Body $body
}

function Disable-OktaAuthorizationServer
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSShouldProcess", "")]
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param (
        [Parameter(Mandatory)]
        [Alias('Id')]
        [string] $AuthorizationServerId
    )
    Invoke-OktaApi -RelativeUri "authorizationServers/$AuthorizationServerId/lifecycle/deactivate" -Method POST
}

function Enable-OktaAuthorizationServer
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSShouldProcess", "")]
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [Alias('Id')]
        [string] $AuthorizationServerId
    )
    Invoke-OktaApi -RelativeUri "authorizationServers/$AuthorizationServerId/lifecycle/activate" -Method POST
}

function Remove-OktaAuthorizationServer
{
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param(
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias('Id')]
        [string] $AuthorizationServerId
    )

    process {
        Set-StrictMode -Version Latest

        $auth = Get-OktaAuthorizationServer -AuthorizationServerId $AuthorizationServerId
        if ($auth) {
            if ($PSCmdlet.ShouldProcess($auth.Name,"Remove AuthorizationServer")) {
                Disable-OktaAuthorizationServer -AuthorizationServerId $AuthorizationServerId
                Invoke-OktaApi -RelativeUri "authorizationServers/$AuthorizationServerId" -Method DELETE
            }
        } else {
            Write-Warning "AuthorizationServer with id '$AuthorizationServerId' not found"
        }
    }
}
