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
        [uint] $Limit,
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

.PARAMETER Audience
Parameter description

.PARAMETER Issuer
Parameter description

.PARAMETER Description
Parameter description

.EXAMPLE
New-OktaAuthorizationServer -Name RelianceApi -Audience "http://cccis.com/reliance/api" -Issuer "http:/cccis.com/reliance"

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
        [string] $Audience,
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
        audiences   = @(
            $Audience
        )
        issuer      = $Issuer
    }
    Invoke-OktaApi -RelativeUri "authorizationServers" -Method POST -Body (ConvertTo-Json $body)
}

function Remove-OktaAuthorizationServer
{
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param(
        [Parameter(Mandatory)]
        [string] $AuthorizationServerId
    )
    Set-StrictMode -Version Latest

    if ($PSCmdlet.ShouldProcess($AuthorizationServerId,"Delete AuthorizationServer")) {
        Invoke-OktaApi -RelativeUri "authorizationServers/$AuthorizationServerId" -Method DELETE
    }
}
