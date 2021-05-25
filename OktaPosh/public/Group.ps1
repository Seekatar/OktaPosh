# https://developer.okta.com/docs/reference/api/groups/
Set-StrictMode -Version Latest

function Get-OktaGroup
{
    [CmdletBinding(DefaultParameterSetName="Query")]
    param (
        [Parameter(Mandatory,ParameterSetName="ById",ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias("Id")]
        [string] $GroupId,
        [Parameter(ParameterSetName="Query",Position=0)]
        [string] $Query,
        [Parameter(ParameterSetName="Query")]
        [string] $Filter,
        [Parameter(ParameterSetName="Query")]
        [string] $Search,
        [Parameter(ParameterSetName="Query")]
        [uint32] $Limit,
        [Parameter(ParameterSetName="Next")]
        [switch] $Next,
        [switch] $Json,
        [Parameter(ParameterSetName="Next")]
        [switch] $NoWarn
    )

    process {
        if ($GroupId) {
            Invoke-OktaApi -RelativeUri "groups/$GroupId" -Method GET -Json:$Json
        } else {
            Invoke-OktaApi -RelativeUri "groups$(Get-QueryParameters -Query $Query -Limit $Limit -Filter $Filter -Search $Search)" -Method GET -Json:$Json -Next:$Next -NoWarn:$NoWarn
        }
    }
}


function New-OktaGroup {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSShouldProcess", "")]
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [string] $Name,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $Description
    )

    process {
        $body = [PSCustomObject]@{
            profile = @{
                name        = $Name
                description = ternary $Description $Description "Added by OktaPosh"
            }
        }

        Invoke-OktaApi -RelativeUri "groups" -Body $body -Method POST
    }
}

function Set-OktaGroup {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSShouldProcess", "")]
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory,ParameterSetName="Object")]
        [PSCustomObject] $Group,

        [Parameter(Mandatory,ValueFromPipeline,ParameterSetName="Separate")]
        [Alias('GroupId')]
        [string] $Id,
        [Parameter(Mandatory,ParameterSetName="Separate")]
        [string] $Name,
        [Parameter(ParameterSetName="Separate")]
        [string] $Description
    )

    process {
        if ($Id) {
            $body = @{
                profile = @{
                    name = $Name
                }
            }
            if ($Description) {
                $body.profile['description'] = $Description
            }
            $Group = [PSCustomObject]$body
        } else {
            $Id = $Group.Id
        }
        Invoke-OktaApi -RelativeUri "groups/$Id" -Body $Group -Method PUT
    }
}

function Remove-OktaGroup {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param(
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias('Id')]
        [string] $GroupId
    )

    process {
        Set-StrictMode -Version Latest

        $group = Get-OktaGroup -GroupId $GroupId
        if ($group) {
            if ($PSCmdlet.ShouldProcess($group.profile.name,"Remove Group")) {
                Invoke-OktaApi -RelativeUri "groups/$GroupId" -Method DELETE
            }
        } else {
            Write-Warning "Group with id '$GroupId' not found"
        }
    }
}

function Get-OktaGroupApp
{
    [CmdletBinding(DefaultParameterSetName="Other")]
    param (
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName,Position=0)]
        [Alias("Id")]
        [string] $GroupId,
        [Parameter(ParameterSetName="Limit")]
        [uint32] $Limit,
        [Parameter(ParameterSetName="Next")]
        [switch] $Next,
        [switch] $Json,
        [Parameter(ParameterSetName="Next")]
        [switch] $NoWarn
    )

    process {
        Invoke-OktaApi -RelativeUri "groups/$GroupId/apps$(Get-QueryParameters -Limit $Limit)" -Method GET -Json:$Json -Next:$Next -NoWarn:$NoWarn
    }
}

function Get-OktaGroupUser
{
    [CmdletBinding(DefaultParameterSetName="Other")]
    param (
        [Parameter(ValueFromPipeline,ValueFromPipelineByPropertyName,Position=0)]
        [Alias("Id")]
        [string] $GroupId,
        [Parameter(ParameterSetName="Limit")]
        [uint32] $Limit,
        [Parameter(ParameterSetName="Next")]
        [switch] $Next,
        [switch] $Json,
        [Parameter(ParameterSetName="Next")]
        [switch] $NoWarn
    )

    process {
        Invoke-OktaApi -RelativeUri "groups/$GroupId/users$(Get-QueryParameters -Limit $Limit)" -Method GET -Json:$Json -Next:$Next -NoWarn:$NoWarn
    }
}

function Add-OktaGroupUser {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSShouldProcess", "")]
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [string] $GroupId,
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias("Id")]
        [string] $UserId,
        [switch] $Json
    )

    process {
        Invoke-OktaApi -RelativeUri "groups/$GroupId/users/$UserId" -Method PUT -Json:$Json
    }
}

function Remove-OktaGroupUser {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSShouldProcess", "")]
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [string] $GroupId,
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias("Id")]
        [string] $UserId,
        [switch] $Json
    )

    process {
        Invoke-OktaApi -RelativeUri "groups/$GroupId/users/$UserId" -Method DELETE -Json:$Json
    }
}