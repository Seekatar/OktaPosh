# https://developer.okta.com/docs/reference/api/policy/
Set-StrictMode -Version Latest

function Get-OktaPolicy
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $AuthorizationServerId,
        [Parameter(Mandatory,ParameterSetName="ById",ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias("Id")]
        [string] $PolicyId,
        [Parameter(ParameterSetName="Query")]
        [string] $Query,
        [switch] $Json
    )

    process {
        if ($PolicyId) {
            Invoke-OktaApi -RelativeUri "authorizationServers/$AuthorizationServerId/policies/$PolicyId" -Method GET -Json:$Json
        } else {
            Find-InResult -Query $Query -Result (Invoke-OktaApi -RelativeUri "authorizationServers/$AuthorizationServerId/policies" -Method GET -Json:$Json)
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

    $body = @{
        type        = "OAUTH_AUTHORIZATION_POLICY"
        status      = ternary $Inactive "INACTIVE" "ACTIVE"
        name        = $Name
        description = ternary $Description $Description "Added by OktaPosh"
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

function Remove-OktaPolicy
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSShouldProcess", "")]
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias("Id")]
        [string] $PolicyId
    )

    process {
        Set-StrictMode -Version Latest

        $policy = Get-OktaPolicy -PolicyId $PolicyId
        if ($policy) {
            if ($PSCmdlet.ShouldProcess($policy.Name,"Remove Policy")) {
                Invoke-OktaApi -RelativeUri "policies/$PolicyId" -Method DELETE
            }
        } else {
            Write-Warning "Policy with id '$PolicyId' not found"
        }
    }
}

function Set-OktaPolicy {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [PSCustomObject] $Policy
    )

    if ($PSCmdlet.ShouldProcess("$($Policy.label)","Update Policy")) {
        Invoke-OktaApi -RelativeUri "policies/$($Policy.id)" -Body $Policy -Method PUT
    }
}

