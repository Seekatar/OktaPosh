Set-StrictMode -Version Latest

function Get-OktaPolicy
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $AuthorizationServerId,
        [Parameter(Mandatory,ParameterSetName="ById",ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias("id")]
        [string] $RuleId,
        [Parameter(ParameterSetName="Query")]
        [string] $Query
    )

    process {
        if ($RuleId) {
            Invoke-OktaApi -RelativeUri "authorizationServers/$AuthorizationServerId/policies" -Method GET
        } else {
            Find-InResult -Query $Query -Result (Invoke-OktaApi -RelativeUri "authorizationServers/$AuthorizationServerId/policies" -Method GET)
        }
    }
}



function New-OktaPolicy
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSShouldProcess", "")]
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [string] $AuthorizationServerId,
        [Parameter(Mandatory)]
        [string] $Name,
        [string] $Description,
        [switch] $Inactive,
        [uint32] $Priority = 1,
        [string[]] $ClientIds
    )

    if (!$Description)
    {
        $Description = "Added by OktaPosh"
    }

    $body = @{
        type        = "OAUTH_AUTHORIZATION_POLICY"
        status      = ternary $Inactive "INACTIVE" "ACTIVE"
        name        = $Name
        description = $Description
        priority    = $Priority
        conditions  = @{
            clients = @{
                include = @()
            }
        }
    }

    if ($ClientIds)
    {
        $body.conditions.clients.include += $ClientIds
    }
    else
    {
        $body.conditions.clients.include += "ALL_CLIENTS"
    }

    Invoke-OktaApi -RelativeUri "authorizationServers/$AuthorizationServerId/policies" -Method POST -Body $body
}


