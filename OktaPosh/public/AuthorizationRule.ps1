Set-StrictMode -Version Latest

function Get-OktaRule
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $AuthorizationServerId,
        [Parameter(Mandatory)]
        [string] $PolicyId,
        [Parameter(Mandatory,ParameterSetName="ById",ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias("Id")]
        [string] $RuleId,
        [Parameter(ParameterSetName="Query")]
        [string] $Query,
        [switch] $Json
    )

    process {
        if ($RuleId) {
            Invoke-OktaApi -RelativeUri "authorizationServers/$AuthorizationServerId/policies/$PolicyId/rules/$RuleId" -Method GET -Json:$Json
        } else {
	        Find-InResult -Query $Query -Result (Invoke-OktaApi -RelativeUri "authorizationServers/$AuthorizationServerId/policies/$PolicyId/rules" -Method GET -Json:$Json)
        }

    }
 }

function New-OktaRule
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSShouldProcess", "")]
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [string] $AuthorizationServerId,
        [Parameter(Mandatory)]
        [string] $PolicyId,
        [Parameter(Mandatory)]
        [string] $Name,
        [switch] $Inactive,
        [uint32] $Priority = 1,
        [Parameter(Mandatory)]
        [ValidateSet("authorization_code", "password", "refresh_token", "client_credentials", "implicit")]
        [string[]] $GrantTypes,
        [string[]] $Scopes = @('*'),
        [string[]] $UserIds,
        [string[]] $GroupIds = "EVERYONE",
        [ValidateRange(5, 1440)]
        [uint32] $AccessTokenLifetimeMinutes = 60,
        [uint32] $RefreshTokenLifetimeMinutes = 0, # 0 = unlimited
        [ValidateRange(1, 1825)]
        [uint32] $RefreshTokenWindowDays = 7
    )
    $body = @{
        type       = "RESOURCE_ACCESS"
        name       = $Name
        status     = ternary $Inactive "INACTIVE" "ACTIVE"
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
    Invoke-OktaApi -RelativeUri "authorizationServers/$AuthorizationServerId/policies/$PolicyId/rules" -Method POST -Body $body
}
