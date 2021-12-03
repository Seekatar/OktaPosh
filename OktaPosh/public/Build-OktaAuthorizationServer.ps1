
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
    [string[]] $Scopes,
    [switch] $Quiet
)
    Set-StrictMode -Version Latest
    $prevErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = "Stop"
    $prevInformationPreference = $InformationPreference
    $InformationPreference = ternary $Quiet "SilentlyContinue" "Continue"

    try {

        $authServer = Get-OktaAuthorizationServer -Query $Name
        if ($authServer) {
            Write-Information "Found auth server '$Name' $($authServer.id)"
        } else {
            $authServer = New-OktaAuthorizationServer -Name $Name `
                                    -Audiences $audience `
                                    -Description $Description
            if ($authServer -or $WhatIfPreference) {
                Write-Information "Created '$Name' $($authServer.id)"
            } else {
                throw "Failed to create '$authServer'"
            }
        }

        $existingScopes = Get-OktaScope -AuthorizationServerId $authServer.id | Select-Object -ExpandProperty name
        $scopesToAdd = $Scopes | Where-Object { $_ -notin $existingScopes }
        if ($scopesToAdd) {
            $null = $scopesToAdd | New-OktaScope -AuthorizationServerId $authServer.id
            Write-Information "    Scopes added: $($scopesToAdd -join ',')"
        } else {
            Write-Information "    All scopes found"
        }

        return $authServer
    } finally {
        $ErrorActionPreference = $prevErrorActionPreference
        $InformationPreference = $prevInformationPreference
    }
}
