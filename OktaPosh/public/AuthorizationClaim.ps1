# https://developer.okta.com/docs/reference/api/authorization-servers/#claim-operations
Set-StrictMode -Version Latest

function Get-OktaClaim
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $AuthorizationServerId,
        [Parameter(Mandatory, ParameterSetName = "ById", ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias("Id")]
        [string] $ClaimId,
        [Parameter(ParameterSetName = "Query")]
        [string] $Query,
        [switch] $Json
    )

    process
    {
        if ($ClaimId)
        {
            Invoke-OktaApi -RelativeUri "authorizationServers/$AuthorizationServerId/claims/$ClaimId" -Method GET -Json:$Json
        }
        else
        {
            Find-InResult -Query $Query -Result (Invoke-OktaApi -RelativeUri "authorizationServers/$AuthorizationServerId/claims" -Method GET -Json:$Json)
        }
    }
}

function New-OktaClaim
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSShouldProcess", "")]
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [string] $AuthorizationServerId,
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Name,
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateSet("EXPRESSION", "GROUPS")]
        [string] $ValueType,
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet("RESOURCE", "IDENTITY")] # Resource = attach to token, Identity = attach to id token
        [string] $ClaimType = "RESOURCE",
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Value,
        [Parameter(ValueFromPipelineByPropertyName)]
        [switch] $Inactive,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string[]] $Scopes,
        [switch] $Json
    )

    process
    {
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

        Invoke-OktaApi -RelativeUri "authorizationServers/$AuthorizationServerId/claims" -Method POST -Body $body -Json:$Json
    }
}

function Remove-OktaClaim
{
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param(
        [Parameter(Mandatory)]
        [string] $AuthorizationServerId,
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias("Id")]
        [string] $ClaimId,
        [switch] $Json
    )

    process
    {
        Set-StrictMode -Version Latest

        $claim = Get-OktaClaim -AuthorizationServerId $AuthorizationServerId -ClaimId $ClaimId
        if ($claim) {
            if ($PSCmdlet.ShouldProcess("$($Claim.name)", "Remove claim"))
            {
                Invoke-OktaApi -RelativeUri "meta/schemas/apps/$AppId/default" -Method DELETE -Json:$Json
            }
        } else {
            Write-Warning "Claim with id '$ClaimId' not found"
        }
    }
}

