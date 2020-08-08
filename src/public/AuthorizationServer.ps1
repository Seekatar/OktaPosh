Set-StrictMode -Version Latest
function Get-OktaAuthorizationServer
{
    param (
        [Parameter(Mandatory)]
        [string] $AuthorizationServerId
    )

    Invoke-OktaApi -RelativeUri "authorizationServers/$AuthorizationServerId" -RawContent:$RawContent
}

<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.PARAMETER Query
Parameter description

.PARAMETER Limit
Parameter description

.PARAMETER After
Parameter description

.EXAMPLE
$relianceAuth = Find-OktaAuthorizationServer -Query Reliance

.NOTES
General notes
#>
function Find-OktaAuthorizationServer
{
    [CmdletBinding()]
    param (
        [string] $Query,
        [uint] $Limit,
        [string] $After
    )

    Invoke-OktaApi -RelativeUri "authorizationServers$(Get-QueryParameters $Query $Limit $After)"
}

<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.PARAMETER Name
Parameter description

.PARAMETER Audience
Parameter description

.PARAMETER Issuer
Parameter description

.PARAMETER Description
Parameter description

.EXAMPLE
New-OktaAuthorizationServer -Name RelianceApi -Audience "http://cccis.com/reliance/api" -Issuer "http:/cccis.com/reliance"

.NOTES
General notes
#>
function New-OktaAuthorizationServer
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $Name,
        [Parameter(Mandatory)]
        [string] $Audience,
        [Parameter(Mandatory)]
        [string] $Issuer,
        [string] $Description
    )

    if (!$Description)
    {
        $Description = $Name
    }

    $body = @{
        name        = $Name
        description = $Description
        audiences   = @(
            $Audience
        )
        issuer      = $Issuer
    }
    Invoke-OktaApi -RelativeUri "authorizationServers" -Method POST -Body (ConvertTo-Json $body)
}

function Remove-OktaAuthorizationServer
{
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param(
        [Parameter(Mandatory)]
        [string] $AuthorizationServerId
    )
    Set-StrictMode -Version Latest

    if ($PSCmdlet.ShouldProcess($AuthorizationServerId,"Delete AuthorizationServer")) {
        Invoke-OktaApi -RelativeUri "authorizationServers/$AuthorizationServerId" -Method DELETE
    }
}

function Find-OktaScope
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $AuthorizationServerId,
        [switch] $IncludeSystem,
        [string] $Query
    )

    $results = Invoke-OktaApi -RelativeUri "authorizationServers/$AuthorizationServerId/scopes" -Method GET
    if ($results -and !$IncludeSystem) {
        $results = $results | Where-Object system -eq $false
    }
    Write-Result -Result $results -Query $Query
}

<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

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

.NOTES
General notes
#>
function New-OktaScope
{
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
            $Description = "$Name - Added by OktaPosh"
        }
        $body = @{
            name            = $Name
            description     = $Description
            metadataPublish = $MetadataPublish ? "ALL_CLIENTS" : "NO_CLIENTS"
            default         = [bool]$DefaultScope
        }

        Invoke-OktaApi -RelativeUri "authorizationServers/$AuthorizationServerId/scopes" -Method POST -Body (ConvertTo-Json $body)
    }

}

function Find-OktaClaim
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $AuthorizationServerId,
        [string] $Query
    )

    Write-Result -Query $Query -Result (Invoke-OktaApi -RelativeUri "authorizationServers/$AuthorizationServerId/claims" -Method GET)
}

<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.PARAMETER AuthorizationServerId
Parameter description

.PARAMETER Name
Parameter description

.PARAMETER ValueType
Parameter description

.PARAMETER ClaimType
RESOURCE (Access token) or IDENTITY (Identity Token)

.PARAMETER Value
Parameter description

.PARAMETER Inactive
Parameter description

.PARAMETER Scopes
Parameter description

.EXAMPLE
New-OktaClaim -AuthorizationServerId ausoqi2fqgcUpYHBS4x6 -Name appName -ValueType EXPRESSION -ClaimType RESOURCE -Value app.profile.appName

.EXAMPLE
New-OktaClaim -AuthorizationServerId ausoqi2fqgcUpYHBS4x6 -Name test -ValueType EXPRESSION -ClaimType RESOURCE -Value app.profile.appName  -Verbose -Scopes "access_token"

.NOTES
General notes
#>
function New-OktaClaim
{
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [string] $AuthorizationServerId,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [string] $Name,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [ValidateSet("EXPRESSION", "GROUPS", "SYSTEM")]
        [string] $ValueType,
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet("RESOURCE", "IDENTITY")]
        [string] $ClaimType,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [string] $Value,
        [Parameter(ValueFromPipelineByPropertyName)]
        [switch] $Inactive,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string[]] $Scopes
    )

    $body = @{
        name      = $Name
        status    = $Inactive ? "INACTIVE" : "ACTIVE"
        valueType = $ValueType
        claimType = $ClaimType
        value     = $Value
    }
    if ($Scopes)
    {
        $body['conditions'] = @{
            scopes = $Scopes
        }
    }

    Invoke-OktaApi -RelativeUri "authorizationServers/$AuthorizationServerId/claims" -Method POST -Body (ConvertTo-Json $body)
}

function Find-OktaPolicy
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $AuthorizationServerId,
        [string] $Query
    )

    Write-Result -Query $Query -Result (Invoke-OktaApi -RelativeUri "authorizationServers/$AuthorizationServerId/policies" -Method GET)
}



function New-OktaPolicy
{
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [string] $AuthorizationServerId,
        [Parameter(Mandatory)]
        [string] $Name,
        [string] $Description,
        [switch] $Inactive,
        [uint] $Priority = 1,
        [string[]] $ClientIds
    )

    if (!$Description)
    {
        $Description = "$Name - Added by OktaPosh"
    }

    $body = @{
        type        = "OAUTH_AUTHORIZATION_POLICY"
        status      = $Inactive ? "INACTIVE" : "ACTIVE"
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

    Invoke-OktaApi -RelativeUri "authorizationServers/$AuthorizationServerId/policies" -Method POST -Body (ConvertTo-Json $body -Depth 5)
}



function Find-OktaRule
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $AuthorizationServerId,
        [Parameter(Mandatory)]
        [string] $PolicyId,
        [string] $Query
    )

    Write-Result -Query $Query -Result (Invoke-OktaApi -RelativeUri "authorizationServers/$AuthorizationServerId/policies/$PolicyId/rules" -Method GET)
}

<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.PARAMETER AuthorizationServerId
Parameter description

.PARAMETER PolicyId
Parameter description

.PARAMETER Name
Parameter description

.PARAMETER Inactive
Parameter description

.PARAMETER Priority
Parameter description

.PARAMETER GrantTypes
Parameter description

.PARAMETER Scopes
Parameter description

.PARAMETER UserIds
Parameter description

.PARAMETER GroupIds
Parameter description

.PARAMETER AccessTokenLifetimeMinutes
Parameter description

.PARAMETER RefreshTokenLifetimeMinutes
Parameter description

.PARAMETER RefreshTokenWindowDays
Parameter description

.EXAMPLE
New-OktaRule -AuthorizationServerId $reliance.id -Name "Allow DRE" -PolicyId $drePolicy.id -Priority 1 -GrantTypes client_credentials -Scopes get_item,access_token,save_item

.NOTES
General notes
#>
function New-OktaRule
{
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [string] $AuthorizationServerId,
        [Parameter(Mandatory)]
        [string] $PolicyId,
        [Parameter(Mandatory)]
        [string] $Name,
        [switch] $Inactive,
        [uint] $Priority = 1,
        [Parameter(Mandatory)]
        [ValidateSet("authorization_code", "password", "refresh_token", "client_credentials")]
        [string[]] $GrantTypes,
        [string[]] $Scopes,
        [string[]] $UserIds,
        [string[]] $GroupIds = "EVERYONE",
        [ValidateRange(5, 1440)]
        [uint] $AccessTokenLifetimeMinutes = 60,
        [uint] $RefreshTokenLifetimeMinutes = 0, # 0 = unlimited
        [ValidateRange(1, 1825)]
        [uint] $RefreshTokenWindowDays = 7
    )
    $body = @{
        type       = "RESOURCE_ACCESS"
        name       = $Name
        status     = $Inactive ? "INACTIVE" : "ACTIVE"
        priority   = $Priority
        conditions = @{
            people     = @{
                users  = @{
                    include = @()
                    exclude = @()
                }
                groups = @{
                    include = @($GroupIds)
                    exclude = @()
                }
            }
            grantTypes = @{
                include = @($GrantTypes)
            }
            scopes = @{
                include = @()
            }
        }
        actions    = @{
            token = @{
                accessTokenLifetimeMinutes  = $AccessTokenLifetimeMinutes
                refreshTokenLifetimeMinutes = $RefreshTokenLifetimeMinutes
                refreshTokenWindowMinutes   = $RefreshTokenWindowDays*24*60
            }
        }
    }
    if ($Scopes)
    {
        $body.conditions.scopes.include += $Scopes
    }
    if ($UserIds)
    {
        $body.conditions.users.include += $UserIds
    }
    Invoke-OktaApi -RelativeUri "authorizationServers/$AuthorizationServerId/policies/$PolicyId/rules" -Method POST -Body (ConvertTo-Json $body -Depth 5)
}