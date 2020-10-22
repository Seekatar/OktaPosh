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
    [Parameter(Mandatory)]
    [string] $issuer,
    [string] $claimName
)

    $authServer = Get-OktaAuthorizationServer -Query $authServerName
    if ($authServer) {
        Write-Host "Found auth server '$authServerName' $($authServer.id)"
    } else {
        $authServer = New-OktaAuthorizationServer -Name $authServerName `
            -Audiences $audience `
            -Issuer $issuer `
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
    if ($claimName) {
        $claim = Get-OktaClaim -AuthorizationServerId $authServer.id -Query $claimName
        if ($claim) {
            Write-Host "    Found '$claimName' Claim"
        } else {
            $claim = New-OktaClaim -AuthorizationServerId $authServer.id -Name $claimName -ValueType EXPRESSION -ClaimType RESOURCE -Value "app.profile.$claimName" -Scopes "access:token"
            Write-Host "    Added '$claimName' Claim"
        }
    }
    return $authServer
}
