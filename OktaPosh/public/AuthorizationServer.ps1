# https://developer.okta.com/docs/reference/api/authorization-servers/
Set-StrictMode -Version Latest

function Get-OktaAuthorizationServer
{
    param (
        [Parameter(Mandatory,ParameterSetName="ById",ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias("Id")]
        [string] $AuthorizationServerId,
        [Parameter(ParameterSetName="Query")]
        [string] $Query,
        [Parameter(ParameterSetName="Query")]
        [uint32] $Limit,
        [Parameter(ParameterSetName="Query")]
        [string] $After,
        [switch] $Json
    )

    process {
        if ($AuthorizationServerId) {
            Invoke-OktaApi -RelativeUri "authorizationServers/$AuthorizationServerId" -Json:$Json
        } else {
            Invoke-OktaApi -RelativeUri "authorizationServers$(Get-QueryParameters $Query $Limit $After)" -Json:$Json
        }
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
        [Parameter(Mandatory)]
        [string] $Issuer,
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
        issuer      = $Issuer
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
        issuerMode  = 'ORG_URL' # required
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

if (!(Test-Path alias:goktaauth)) {
    New-Alias goktaauth Get-OktaAuthorizationServer
}