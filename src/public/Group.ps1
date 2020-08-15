Set-StrictMode -Version Latest
function Get-OktaGroup
{
    [CmdletBinding(DefaultParameterSetName="Query")]
    param (
        [Parameter(Mandatory,ParameterSetName="ById",ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias("id")]
        [string] $GroupId,
        [Parameter(ParameterSetName="Query")]
        [string] $Query,
        [Parameter(ParameterSetName="Query")]
        [uint] $Limit,
        [Parameter(ParameterSetName="Query")]
        [string] $After
    )

    process {
        if ($GroupId) {
            Invoke-OktaApi -RelativeUri "groups/$GroupId" -Method GET
        } else {
            Write-Result -Query $Query -Result (Invoke-OktaApi -RelativeUri "groups$(Get-QueryParameters $Query $Limit $After)" -Method GET)
        }
    }
}


function New-OktaGroup
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSShouldProcess", "")]
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory,ValueFromPipeline)]
        [string] $Name,
        [Parameter(Mandatory)]
        [string] $Description,
        [hashtable] $Properties
    )

    process {
        $body = @{
            name      = $Name
            status    = $Inactive ? "INACTIVE" : "ACTIVE"
            valueType = $ValueType
            groupType = $GroupType
            value     = $Value
        }
        if ($Scopes)
        {
            $body['conditions'] = @{
                scopes = $Scopes
            }
        }

        Invoke-OktaApi -RelativeUri "authorizationServers/$AuthorizationServerId/groups" -Method POST -Body (ConvertTo-Json $body)
    }
}
