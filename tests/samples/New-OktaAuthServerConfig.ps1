
function New-OktaAuthServerConfig
{
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [string] $AuthServerName,
    [Parameter(Mandatory)]
    [string[]] $Scopes,
    [Parameter(Mandatory)]
    [string] $Audience,
    [Parameter(Mandatory)]
    [string] $Description,
    [HashTable[]] $Claims,
    [Parameter(Mandatory)]
    [string[]] $GroupNames
)
    Set-StrictMode -Version Latest
    $prevErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = "Stop"

    try {

        $authServer = Get-OktaAuthorizationServer -Query $AuthServerName
        if ($authServer) {
            Write-Host "Found auth server '$AuthServerName' $($authServer.id)"
        } else {
            $authServer = New-OktaAuthorizationServer -Name $AuthServerName `
                -Audiences $audience `
                -Description $Description
            if ($authServer) {
                Write-Host "Created '$AuthServerName' $($authServer.id)"
            } else {
                throw "Failed to create '$authServer'"
            }
        }

        $existingScopes = Get-OktaScope -AuthorizationServerId $authServer.id | Select-Object -ExpandProperty name
        $scopesToAdd = $Scopes | Where-Object { $_ -notin $existingScopes }
        if ($scopesToAdd) {
            $null = $scopesToAdd | New-OktaScope -AuthorizationServerId $authServer.id
            Write-Host "    Scopes added: $($scopesToAdd -join ',')"
        } else {
            Write-Host "    All scopes found"
        }

        $existingClaims = Get-OktaClaim -AuthorizationServerId $authServer.id | Select-Object -ExpandProperty name
        $Claims = $Claims | Where-Object { $_.name -notin $existingClaims }
        if ($Claims) {
            $null = $Claims | ForEach-Object { [PSCustomObject]$_ } | New-OktaClaim -AuthorizationServerId $authServer.id
            Write-Host "    Claims added: $($Claims.name -join ',')"
        } else {
            Write-Host "    All claims found"
        }

        return $authServer
    } finally {
        $ErrorActionPreference = $prevErrorActionPreference
    }
}
