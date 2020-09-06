Set-StrictMode -Version Latest

function Get-OktaScope
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $AuthorizationServerId,
        [Parameter(Mandatory,ParameterSetName="ById",ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias("id")]
        [string] $ScopeId,
        [Parameter(ParameterSetName="Query")]
        [string] $Query,
        [switch] $IncludeSystem
    )

    process {
        if ($ScopeId) {
            Invoke-OktaApi -RelativeUri "authorizationServers/$AuthorizationServerId/scopes/$ScopeId" -Method GET
        } else {
            $results = Invoke-OktaApi -RelativeUri "authorizationServers/$AuthorizationServerId/scopes" -Method GET
            if ($results -and !$IncludeSystem) {
                $results = $results | Where-Object system -eq $false
            }
            Find-InResult -Result $results -Query $Query
        }
    }
}

<#
.SYNOPSIS
Add an Okta Authorization Scope

.PARAMETER AuthorizationServerId
Parameter description

.PARAMETER Name
Parameter description

.PARAMETER Description
Parameter description

.PARAMETER MetadataPublish
Parameter description

.PARAMETER DefaultScope
Parameter description

.EXAMPLE
"access_token","get_item","save_item","remove_item" | New-OktaScope -AuthorizationServerId ausoqi2fqgcUpYHBS4x6 -Description "Added via script"

Add four scopes
#>
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

        Invoke-OktaApi -RelativeUri "authorizationServers/$AuthorizationServerId/scopes" -Method POST -Body (ConvertTo-Json $body)
    }

}
