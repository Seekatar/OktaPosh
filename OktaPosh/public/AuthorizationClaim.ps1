# https://developer.okta.com/docs/reference/api/authorization-servers/#claim-operations
Set-StrictMode -Version Latest

function Get-OktaClaim
{
    [CmdletBinding(DefaultParameterSetName="Query")]
    param (
        [Parameter(Mandatory,Position=0)]
        [string] $AuthorizationServerId,
        [Parameter(Mandatory, ParameterSetName = "ById", ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias("Id")]
        [string] $ClaimId,
        [Parameter(ParameterSetName="Query",Position=0)]
        [string] $Query,
        [switch] $Json
    )

    process
    {
        $ClaimId = testQueryForId $ClaimId $Query 'ocl'
        if ($ClaimId) {
            Invoke-OktaApi -RelativeUri "authorizationServers/$AuthorizationServerId/claims/$ClaimId" -Method GET -Json:$Json
        } else {
            Find-InResult -Query $Query -Result (Invoke-OktaApi -RelativeUri "authorizationServers/$AuthorizationServerId/claims" -Method GET -Json:$Json)
        }
    }
}

function New-OktaClaim
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSShouldProcess", "")]
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory,Position=0)]
        [string] $AuthorizationServerId,
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Name,
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateSet("EXPRESSION", "GROUPS")]
        [string] $ValueType,
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet("STARTS_WITH", "EQUALS", "CONTAINS", "REGEX", "")]
        [string] $GroupFilterType,
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet("RESOURCE", "IDENTITY", "ACCESS_TOKEN", "ID_TOKEN")] # Resource = attach to token, Identity = attach to id token
        [string] $ClaimType = "RESOURCE",
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Value,
        [Parameter(ValueFromPipelineByPropertyName)]
        [switch] $Inactive,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string[]] $Scopes,
        [bool] $AlwayIncludeInToken = $true,
        [switch] $Json
    )

    process
    {
        if ($ClaimType -eq "ACCESS_TOKEN") {
            $ClaimType = "RESOURCE"
        } elseif ($ClaimType -eq "ID_TOKEN") {
            $ClaimType = "IDENTITY"
        }
        $body = @{
            name      = $Name
            status    = ternary $Inactive "INACTIVE" "ACTIVE"
            valueType = $ValueType
            claimType = $ClaimType
            value     = $Value
        }
        if ($ClaimType -eq "IDENTITY") {
            $body['alwaysIncludeInToken'] = $AlwayIncludeInToken
        }
        if ($Scopes)
        {
            $body['conditions'] = @{
                scopes = $Scopes
            }
        }
        if ($ValueType -eq 'GROUPS') {
            if (!$GroupFilterType) {
                throw "Must supply GroupFilterType for ValueType of GROUPS"
            }
            $body['group_filter_type'] = $GroupFilterType
        }

        Invoke-OktaApi -RelativeUri "authorizationServers/$AuthorizationServerId/claims" -Method POST -Body $body -Json:$Json
    }
}

function Remove-OktaClaim
{
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param(
        [Parameter(Mandatory,Position=0)]
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
            if ($PSCmdlet.ShouldProcess($Claim.Name, "Remove claim"))
            {
                Invoke-OktaApi -RelativeUri "authorizationServers/$AuthorizationServerId/claims/$ClaimId" -Method DELETE -Json:$Json
            }
        } else {
            Write-Warning "Claim with id '$ClaimId' not found"
        }
    }
}

function Set-OktaClaim {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory,Position=0)]
        [string] $AuthorizationServerId,
        [Parameter(Mandatory,Position=1,ValueFromPipeline)]
        [PSCustomObject] $Claim
    )

    process {
        if ($PSCmdlet.ShouldProcess("$($Claim.Name)","Update Claim")) {
            Invoke-OktaApi -RelativeUri "authorizationServers/$AuthorizationServerId/claims/$($Claim.id)" -Body $Claim -Method PUT
        }
    }
}

