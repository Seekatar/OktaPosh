function New-OktaAuthServerConfig
{
param(
    [Parameter(Mandatory)]
    [string] $authServerName,
    [Parameter(Mandatory)]
    [string[]] $scopes,
    [Parameter(Mandatory)]
    [string] $audience,
    [Parameter(Mandatory)]
    [string] $description,
    [HashTable[]] $claims
)
    Set-StrictMode -Version Latest
    $ErrorActionPreference = "Stop"

    $authServer = Get-OktaAuthorizationServer -Query $authServerName
    if ($authServer) {
        Write-Host "Found auth server '$authServerName' $($authServer.id)"
    } else {
        $authServer = New-OktaAuthorizationServer -Name $authServerName `
            -Audiences $audience `
            -Description $description
        if ($authServer) {
            Write-Host "Created '$authServerName' $($authServer.id)"
        } else {
            throw "Failed to create '$authServer'"
        }
    }

    $existingScopes = Get-OktaScope -AuthorizationServerId $authServer.id | Select-Object -ExpandProperty name
    $scopes = $scopes | Where-Object { $_ -notin $existingScopes }
    if ($scopes) {
        $null = $scopes | New-OktaScope -AuthorizationServerId $authServer.id
        Write-Host "    Scopes added: $($scopes -join ',')"
    } else {
        Write-Host "    All scopes found"
    }

    # add appname claim to all scopes
    foreach($c in $claims) {
        $claim = Get-OktaClaim -AuthorizationServerId $authServer.id -Query $c.name
        if ($claim) {
            Write-Host "    Found '$($c.name)' Claim"
        } else {
            $claim = New-OktaClaim -AuthorizationServerId $authServer.id `
                                   -Name $c.name `
                                   -ValueType $c.valueType `
                                   -GroupFilterType $c['groupFilterType'] `
                                   -ClaimType $c.claimType `
                                   -Value $c.value
            Write-Host "    Added '$($c.name)' Claim"
        }
    }
    return $authServer
}
