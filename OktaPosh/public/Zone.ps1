# https://developer.okta.com/docs/reference/api/zones/

Set-StrictMode -Version Latest

function Disable-OktaZone
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSShouldProcess", "")]
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [Alias("Id")]
        [string] $ZoneId
    )
    Invoke-OktaApi -RelativeUri "zones/$ZoneId/lifecycle/deactivate" -Method POST
}

function Enable-OktaZone
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSShouldProcess", "")]
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [Alias("Id")]
        [string] $ZoneId
    )
    Invoke-OktaApi -RelativeUri "zones/$ZoneId/lifecycle/activate" -Method POST
}

function Get-OktaZone
{
    [CmdletBinding(DefaultParameterSetName="Query")]
    param (
        [Parameter(Mandatory,ParameterSetName="ById",ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias("Id")]
        [string] $ZoneId,
        [Parameter(ParameterSetName="Query")]
        [ValidateSet('BLOCKLIST','POLICY',IgnoreCase=$false)]
        [string] $Usage,
        [Parameter(ParameterSetName="Query")]
        [uint32] $Limit,
        [Parameter(ParameterSetName="Next")]
        [switch] $Next,
        [switch] $Json,
        [Parameter(ParameterSetName="Next")]
        [switch] $NoWarn
    )

    process {
        if ($ZoneId) {
            Invoke-OktaApi -RelativeUri "zones/$ZoneId" -Method GET -Json:$Json
        } else {
            $filter = $null
            if ($Usage) {
                $filter = "usage eq `"$Usage`""
            }
            Invoke-OktaApi -RelativeUri "zones$(Get-QueryParameters -Limit $Limit -Filter $filter)" -Method GET -Json:$Json -Next:$Next -NoWarn:$NoWarn
        }
    }
}

function ipAddresses( $ips) {

    $ips | ForEach-Object {
        if ($_ -like '*/*') {
            @{type = "CIDR"; value = $_}
        } else {
            @{type = "RANGE"; value = $_}
        }
    }
}

function New-OktaBlockListZone {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSShouldProcess", "")]
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [string] $Name,
        [string[]] $GatewayIps = @(),
        [switch] $Inactive
    )

    process {
        $body = [PSCustomObject]@{
            type = "IP"
            name = $Name
            status = ternary $Inactive "INACTIVE" "ACTIVE"
            usage = "BLOCKLIST"
            gateways = ipAddresses $GatewayIps
        }
        Invoke-OktaApi -RelativeUri "zones" -Body $body -Method POST
    }
}

function New-OktaDynamicZone {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSShouldProcess", "")]
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [string] $Name,
        [hashtable[]] $Locations = @(),
        [string[]] $ASNs = @(),
        [ValidateSet('Any','AnyProxy', 'Tor','NotTorAnonymizer',IgnoreCase=$false)]
        [string] $ProxyType = 'Any',
        [ValidateSet('BLOCKLIST','POLICY',IgnoreCase=$false)]
        [string] $Usage = 'POLICY',
        [switch] $Inactive
    )

    process {
        $MyProxyType = $ProxyType
        if ($ProxyType -eq 'AnyProxy') {
            $MyProxyType = 'Any'
        } elseif ($ProxyType -eq 'Any') {
            $MyProxyType = $null
        }
        $body = [PSCustomObject]@{
            type = "DYNAMIC"
            name = $Name
            status = ternary $Inactive "INACTIVE" "ACTIVE"
            usage = $Usage
            locations = $Locations
            proxyType = $MyProxyType
            asns = $ASNs
        }
        Invoke-OktaApi -RelativeUri "zones" -Body $body -Method POST
    }
}

function New-OktaPolicyZone {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSShouldProcess", "")]
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [string] $Name,
        [string[]] $GatewayIps = @(),
        [string[]] $ProxyIps = @(),
        [switch] $Inactive
    )

    process {
        $body = [PSCustomObject]@{
            type = "IP"
            name = $Name
            status = ternary $Inactive "INACTIVE" "ACTIVE"
            usage = "POLICY"
            gateways = ipAddresses $GatewayIps
            proxies = ipAddresses $ProxyIps
        }

        Invoke-OktaApi -RelativeUri "zones" -Body $body -Method POST
    }
}

function Set-OktaZone {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSShouldProcess", "")]
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory,Position=0,ValueFromPipeline)]
        [PSCustomObject] $Zone
    )

    process {
        $Id = $Zone.Id
        Invoke-OktaApi -RelativeUri "zones/$Id" -Body $Zone -Method PUT
    }
}

function Remove-OktaZone {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param(
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias('Id')]
        [string] $ZoneId
    )

    process {
        Set-StrictMode -Version Latest

        $zone = Get-OktaZone -ZoneId $ZoneId
        if ($zone) {
            if ($PSCmdlet.ShouldProcess($zone.name,"Remove Zone")) {
                Invoke-OktaApi -RelativeUri "zones/$ZoneId" -Method DELETE
            }
        } else {
            Write-Warning "Zone with id '$ZoneId' not found"
        }
    }
}
