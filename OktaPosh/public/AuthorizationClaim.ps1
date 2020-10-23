Set-StrictMode -Version Latest
<#
.SYNOPSIS
Get one of more Claims for an AuthorizationServer
#>
function Get-OktaClaim
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $AuthorizationServerId,
        [Parameter(Mandatory,ParameterSetName="ById",ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias("id")]
        [string] $ClaimId,
        [Parameter(ParameterSetName="Query")]
        [string] $Query,
        [switch] $Json
    )

    process {
        if ($ClaimId) {
            Invoke-OktaApi -RelativeUri "authorizationServers/$AuthorizationServerId/claims/$ClaimId" -Method GET -RawContent:$Json
        } else {
            Find-InResult -Query $Query -Result (Invoke-OktaApi -RelativeUri "authorizationServers/$AuthorizationServerId/claims" -Method GET -RawContent:$Json)
        }
    }
}

<#
.SYNOPSIS
Create a new Okta Claim

.PARAMETER AuthorizationServerId
Parameter description

.PARAMETER Name
Parameter description

.PARAMETER ValueType
Parameter description

.PARAMETER ClaimType
RESOURCE (Access token) or IDENTITY (Identity Token)

.PARAMETER Value
Parameter description

.PARAMETER Inactive
Parameter description

.PARAMETER Scopes
Parameter description

.EXAMPLE
New-OktaClaim -AuthorizationServerId ausoqi2fqgcUpYHBS4x6 -Name appName -ValueType EXPRESSION -ClaimType RESOURCE -Value app.profile.appName

.EXAMPLE
New-OktaClaim -AuthorizationServerId ausoqi2fqgcUpYHBS4x6 -Name test -ValueType EXPRESSION -ClaimType RESOURCE -Value app.profile.appName  -Verbose -Scopes "access_token"

#>
function New-OktaClaim
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSShouldProcess", "")]
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [string] $AuthorizationServerId,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [string] $Name,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [ValidateSet("EXPRESSION", "GROUPS", "SYSTEM")]
        [string] $ValueType,
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet("RESOURCE", "IDENTITY")]
        [string] $ClaimType,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [string] $Value,
        [Parameter(ValueFromPipelineByPropertyName)]
        [switch] $Inactive,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string[]] $Scopes
    )

    process {
        $body = @{
            name      = $Name
            status    = ternary $Inactive "INACTIVE" "ACTIVE"
            valueType = $ValueType
            claimType = $ClaimType
            value     = $Value
        }
        if ($Scopes)
        {
            $body['conditions'] = @{
                scopes = $Scopes
            }
        }

        Invoke-OktaApi -RelativeUri "authorizationServers/$AuthorizationServerId/claims" -Method POST -Body $body
    }
}
