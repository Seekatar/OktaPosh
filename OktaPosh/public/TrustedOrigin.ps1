# https://developer.okta.com/docs/reference/api/trustedorigins/
Set-StrictMode -Version Latest

function Get-OktaTrustedOrigin
{
    [CmdletBinding(DefaultParameterSetName="Query")]
    param (
        [Parameter(Mandatory,ParameterSetName="ById",ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias("Id")]
        [string] $TrustedOriginId,
        [Parameter(ParameterSetName="Query")]
        [string] $Filter,
        [Parameter(ParameterSetName="Query")]
        [uint32] $Limit,
        [Parameter(ParameterSetName="Query")]
        [string] $After,
        [switch] $Json
    )

    process {
        if ($TrustedOriginId) {
            Invoke-OktaApi -RelativeUri "trustedOrigins/$TrustedOriginId" -Method GET -Json:$Json
        } else {
            Invoke-OktaApi -RelativeUri "trustedOrigins$(Get-QueryParameters -Limit $Limit -After $After -Filter $Filter)" -Method GET -Json:$Json
        }
    }
}


function New-OktaTrustedOrigin {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSShouldProcess", "")]
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [string] $Name,
        [Parameter(Mandatory)]
        [string] $Origin,
        [switch] $CORS,
        [switch] $Redirect
    )

    $body = [PSCustomObject]@{
        name        = $Name
        origin      = $Origin
        scopes      = @()
    }
    if ($CORS) {
        $body.scopes += @{ type = 'CORS'}
    }
    if ($Redirect) {
        $body.scopes += @{ type = 'REDIRECT'}
    }

    Invoke-OktaApi -RelativeUri "trustedOrigins" -Body $body -Method POST
}

function Set-OktaTrustedOrigin {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSShouldProcess", "")]
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [PSCustomObject] $TrustedOrigin
    )

    Invoke-OktaApi -RelativeUri "trustedOrigins" -Body $TrustedOrigin -Method PUT
}

<#
.SYNOPSIS
Delete a trustedorigin

.PARAMETER TrustedOriginId
Id of the trustedorigin
#>
function Remove-OktaTrustedOrigin {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param(
        [Parameter(Mandatory,ValueFromPipeline)]
        [Alias('Id')]
        [string] $TrustedOriginId
    )

    process {
        Set-StrictMode -Version Latest

        if ($PSCmdlet.ShouldProcess($TrustedOriginId,"Remove TrustedOrigin")) {
            Invoke-OktaApi -RelativeUri "trustedOrigins/$TrustedOriginId" -Method DELETE
        }
    }
}
