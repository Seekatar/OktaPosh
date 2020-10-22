# https://developer.okta.com/docs/reference/api/groups/
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
        [string] $Filter,
        [Parameter(ParameterSetName="Query")]
        [string] $Search,
        [Parameter(ParameterSetName="Query")]
        [uint32] $Limit,
        [Parameter(ParameterSetName="Query")]
        [string] $After
    )

    process {
        if ($GroupId) {
            Invoke-OktaApi -RelativeUri "groups/$GroupId" -Method GET
        } else {
            Invoke-OktaApi -RelativeUri "groups$(Get-QueryParameters -Query $Query -Limit $Limit -After $After -Filter $Filter -Search $Search)" -Method GET
        }
    }
}


function New-OktaGroup {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSShouldProcess", "")]
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [string] $Name,
        [string] $Description
    )

    if (!$Description) {
        $Description = "Added by OktaPosh"
    }

    $body = [PSCustomObject]@{
        profile = @{
            name        = $Name
            description = $Description
        }
    }

    Invoke-OktaApi -RelativeUri "groups" -Body $body -Method POST
}

function Set-OktaGroup {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSShouldProcess", "")]
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [Alias('Id')]
        [string] $GroupId,
        [Parameter(Mandatory)]
        [string] $Name,
        [switch] $Description
    )

    if (!$Description) {
        $Description = "Updated by OktaPosh"
    }

    $body = [PSCustomObject]@{
        name        = $Name
        description = $Description
    }

    Invoke-OktaApi -RelativeUri "groups/$GroupId" -Body $body -Method PUT
}

<#
.SYNOPSIS
Delete a group

.PARAMETER GroupId
Id of the group
#>
function Remove-OktaGroup {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param(
        [Parameter(Mandatory,ValueFromPipeline)]
        [Alias('Id')]
        [string] $GroupId
    )

    process {
        Set-StrictMode -Version Latest

        if ($PSCmdlet.ShouldProcess($GroupId,"Remove Group")) {
            Invoke-OktaApi -RelativeUri "groups/$GroupId" -Method DELETE
        }
    }
}

function Get-OktaGroupApp
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,ParameterSetName="ById",ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias("id")]
        [string] $GroupId,
        [Parameter()]
        [uint32] $Limit,
        [Parameter()]
        [string] $After
    )

    process {
        Invoke-OktaApi -RelativeUri "groups/$GroupId/apps$(Get-QueryParameters -Limit $Limit -After $After)" -Method GET
    }
}

function Get-OktaGroupUser
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,ParameterSetName="ById",ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias("id")]
        [string] $GroupId,
        [Parameter()]
        [uint32] $Limit,
        [Parameter()]
        [string] $After
    )

    process {
        Invoke-OktaApi -RelativeUri "groups/$GroupId/users$(Get-QueryParameters -Limit $Limit -After $After)" -Method GET
    }
}
