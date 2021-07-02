
function Build-OktaAuthorizationServer
{
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [string] $Name,
    [Parameter(Mandatory)]
    [string] $Audience,
    [Parameter(Mandatory)]
    [string] $Description,
    [Parameter(Mandatory)]
    [string[]] $Scopes
)
    Set-StrictMode -Version Latest
    $prevErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = "Stop"

    try {

        $authServer = Get-OktaAuthorizationServer -Query $Name
        if ($authServer) {
            Write-Host "Found auth server '$Name' $($authServer.id)"
        } else {
            $authServer = New-OktaAuthorizationServer -Name $Name `
                                    -Audiences $audience `
                                    -Description $Description
            if ($authServer) {
                Write-Host "Created '$Name' $($authServer.id)"
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

        return $authServer
    } finally {
        $ErrorActionPreference = $prevErrorActionPreference
    }
}
