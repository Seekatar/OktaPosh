# https://developer.okta.com/docs/reference/api/authorization-servers/#scope-operations
Set-StrictMode -Version Latest

function Get-OktaScope
{
    [CmdletBinding(DefaultParameterSetName="Query")]
    param (
        [Parameter(Mandatory,Position=0)]
        [string] $AuthorizationServerId,
        [Parameter(Mandatory,ParameterSetName="ById",ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias("Id")]
        [string] $ScopeId,
        [Parameter(ParameterSetName="Query",Position=1)]
        [string] $Query,
        [switch] $IncludeSystem,
        [switch] $Json
    )

    process {
        $ScopeId = testQueryForId $ScopeId $Query 'scp'
        if ($ScopeId) {
            Invoke-OktaApi -RelativeUri "authorizationServers/$AuthorizationServerId/scopes/$ScopeId" -Method GET -Json:$Json
        } else {
            $results = Invoke-OktaApi -RelativeUri "authorizationServers/$AuthorizationServerId/scopes" -Method GET -Json:$Json
            if ($results -and !$IncludeSystem -and !$Json) {
                $results = $results | Where-Object system -eq $false
            }
            Find-InResult -Result $results -Query $Query
        }
    }
}

function New-OktaScope
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSShouldProcess", "")]
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory,Position=0)]
        [string] $AuthorizationServerId,
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string] $Name,
        [string] $Description,
        [switch] $MetadataPublish,
        [switch] $DefaultScope
    )

    process
    {
        $body = @{
            name            = $Name
            description = ternary $Description $Description "Added by OktaPosh"
            metadataPublish = ternary $MetadataPublish "ALL_CLIENTS" "NO_CLIENTS"
            default         = [bool]$DefaultScope
        }

        Invoke-OktaApi -RelativeUri "authorizationServers/$AuthorizationServerId/scopes" -Method POST -Body $body
    }

}
function Remove-OktaScope
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSShouldProcess", "")]
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param (
        [Parameter(Mandatory,Position=0)]
        [string] $AuthorizationServerId,
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias("Id")]
        [string] $ScopeId
    )

    process {
        Set-StrictMode -Version Latest

        $scope = Get-OktaScope -AuthorizationServerId $AuthorizationServerId -ScopeId $ScopeId
        if ($scope) {
            if ($PSCmdlet.ShouldProcess($scope.Name,"Remove Scope")) {
                Invoke-OktaApi -RelativeUri "authorizationServers/$AuthorizationServerId/scopes/$ScopeId" -Method DELETE
            }
        } else {
            Write-Warning "Scope with id '$ScopeId' not found for auth $AuthorizationServerId "
        }
    }
}

function Set-OktaScope {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory,Position=0)]
        [string] $AuthorizationServerId,
        [Parameter(Mandatory,Position=1,ValueFromPipeline)]
        [PSCustomObject] $Scope
    )

    process {
        if ($PSCmdlet.ShouldProcess("$($Scope.Name)","Update Scope")) {
            Invoke-OktaApi -RelativeUri "authorizationServers/$AuthorizationServerId/scopes/$($Scope.id)" -Body $Scope -Method PUT
        }
    }
}

