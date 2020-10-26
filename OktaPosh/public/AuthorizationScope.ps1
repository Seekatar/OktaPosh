Set-StrictMode -Version Latest

function Get-OktaScope
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $AuthorizationServerId,
        [Parameter(Mandatory,ParameterSetName="ById",ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias("Id")]
        [string] $ScopeId,
        [Parameter(ParameterSetName="Query")]
        [string] $Query,
        [switch] $IncludeSystem,
        [switch] $Json
    )

    process {
        if ($ScopeId) {
            Invoke-OktaApi -RelativeUri "authorizationServers/$AuthorizationServerId/scopes/$ScopeId" -Method GET -Json:$Json
        } else {
            $results = Invoke-OktaApi -RelativeUri "authorizationServers/$AuthorizationServerId/scopes" -Method GET -Json:$Json
            if ($results -and !$IncludeSystem) {
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
        [Parameter(Mandatory)]
        [string] $AuthorizationServerId,
        [Parameter(Mandatory, ValueFromPipeline)]
        [string] $Name,
        [string] $Description,
        [switch] $MetadataPublish,
        [switch] $DefaultScope
    )

    process
    {
        if (!$Description)
        {
            $Description = "Added by OktaPosh"
        }
        $body = @{
            name            = $Name
            description     = $Description
            metadataPublish = ternary $MetadataPublish "ALL_CLIENTS" "NO_CLIENTS"
            default         = [bool]$DefaultScope
        }

        Invoke-OktaApi -RelativeUri "authorizationServers/$AuthorizationServerId/scopes" -Method POST -Body $body
    }

}
