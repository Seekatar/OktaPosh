# https://developer.okta.com/docs/reference/api/authorization-servers/
Set-StrictMode -Version Latest

<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.PARAMETER AuthorizationServerId
Parameter description

.PARAMETER Query
Parameter description

.PARAMETER Limit
Parameter description

.PARAMETER After
Parameter description

.EXAMPLE
$relianceAuth = Get-OktaAuthorizationServer -Query Reliance

.NOTES
General notes
#>
function Get-OktaAuthorizationServer
{
    param (
        [Parameter(Mandatory,ParameterSetName="ById",ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias("id")]
        [string] $AuthorizationServerId,
        [Parameter(ParameterSetName="Query")]
        [string] $Query,
        [Parameter(ParameterSetName="Query")]
        [uint32] $Limit,
        [Parameter(ParameterSetName="Query")]
        [string] $After
    )

    process {
        if ($AuthorizationServerId) {
            Invoke-OktaApi -RelativeUri "authorizationServers/$AuthorizationServerId"
        } else {
            Invoke-OktaApi -RelativeUri "authorizationServers$(Get-QueryParameters $Query $Limit $After)"
        }
    }
}

<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.PARAMETER Name
Parameter description

.PARAMETER Audiences
Parameter description

.PARAMETER Issuer
Parameter description

.PARAMETER Description
Parameter description

.EXAMPLE
New-OktaAuthorizationServer -Name RelianceApi -Audiences "http://cccis.com/reliance/api" -Issuer "http:/cccis.com/reliance"

.NOTES
General notes
#>
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
        issuer      = $Issuer
    }
    Invoke-OktaApi -RelativeUri "authorizationServers/$AuthorizationServerId" -Method PUT -Body $body
}

function Set-OktaAuthorizationServerActive
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSShouldProcess", "")]
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [Alias('Id')]
        [string] $AuthorizationServerId,
        [switch] $Deactivate
    )
    $activate = ternary $Deactivate 'deactivate' 'activate'
    Invoke-OktaApi -RelativeUri "authorizationServers/$AuthorizationServerId/lifecycle/$activate" -Method POST
}

<#
.SYNOPSIS
Delete an authorization server

.PARAMETER AuthorizationServerId
Id of the auth server
#>
function Remove-OktaAuthorizationServer
{
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param(
        [Parameter(Mandatory,ValueFromPipeline)]
        [Alias('Id')]
        [string] $AuthorizationServerId
    )

    process {
        Set-StrictMode -Version Latest

        if ($PSCmdlet.ShouldProcess($AuthorizationServerId,"Remove AuthorizationServer")) {
            Set-OktaAuthorizationServerActive -AuthorizationServerId $AuthorizationServerId -Deactivate
            Invoke-OktaApi -RelativeUri "authorizationServers/$AuthorizationServerId" -Method DELETE
        }
    }
}

if (!(Test-Path alias:goktaauth)) {
    New-Alias goktaauth Get-OktaAuthorizationServer
}