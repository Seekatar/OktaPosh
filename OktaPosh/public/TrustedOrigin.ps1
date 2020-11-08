# https://developer.okta.com/docs/reference/api/trusted-origins/
Set-StrictMode -Version Latest

function Get-OktaTrustedOrigin
{
    [CmdletBinding(DefaultParameterSetName="Filter")]
    param (
        [Parameter(Mandatory,ParameterSetName="ById",ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias("Id")]
        [string] $TrustedOriginId,
        [Parameter(ParameterSetName="Filter")]
        [string] $Filter,
        [Parameter(ParameterSetName="Filter")]
        [uint32] $Limit,
        [Parameter(ParameterSetName="Next")]
        [switch] $Next,
        [switch] $Json
    )

    process {
        if ($TrustedOriginId) {
            Invoke-OktaApi -RelativeUri "trustedOrigins/$TrustedOriginId" -Method GET -Json:$Json
        } else {
            Invoke-OktaApi -RelativeUri "trustedOrigins$(Get-QueryParameters -Limit $Limit -Filter $Filter)" -Method GET -Json:$Json -Next:$Next
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

    if (!$CORS -and !$Redirect) {
        throw "CORS and/or Redirect must be set"
    }

    $body = @{
        name        = $Name
        origin      = $Origin
    }
    if ($CORS) {
        $body["scopes"] = @(@{ type = 'CORS'})
    }
    if ($Redirect) {
        if (!$body["scopes"]) {
            $body["scopes"] = @()
        }
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

    Invoke-OktaApi -RelativeUri "trustedOrigins/$($TrustedOrigin.Id)" -Body $TrustedOrigin -Method PUT
}

function Remove-OktaTrustedOrigin {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param(
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias('Id')]
        [string] $TrustedOriginId
    )

    process {
        Set-StrictMode -Version Latest

        $to = Get-OktatrustedOrigin -Id $TrustedOriginId
        if ($to) {
            if ($PSCmdlet.ShouldProcess($to.name,"Remove TrustedOrigin")) {
                Invoke-OktaApi -RelativeUri "trustedOrigins/$TrustedOriginId" -Method DELETE
            }
        } else {
            Write-Warning "TrustedOrigin with id '$TrustedOriginId' not found"
        }
    }
}
