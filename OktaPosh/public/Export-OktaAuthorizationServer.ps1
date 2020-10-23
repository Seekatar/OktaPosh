function Export-OktaAuthorizationServer {
    param (
        [Parameter(Mandatory)]
        [Alias("id")]
        [string] $AuthServerId,
        [Parameter(Mandatory)]
        [ValidateScript( { Test-Path $_ -PathType Container })]
        [string] $OutputFolder
    )

    Push-Location $OutputFolder
    try {
        Get-OktaAuthorizationServer -AuthorizationServerId $authServerId -Json | Out-File auth.json -Encoding ascii
        Get-OktaClaim -AuthorizationServerId $authServerId -Json | out-file claims.json -enc  ascii
        Get-OktaScope -AuthorizationServerId $authServerId  -Json | out-file scope.json -enc  ascii
        $policy = Get-OktaPolicy -AuthorizationServerId $authServerId
        $policy | ConvertTo-Json -Depth 10 | out-file policy.json -enc  ascii
        $policy | ForEach-Object {
            $i = 1
            Get-OktaRule -AuthorizationServerId $authServerId -PolicyId $_.id -Json | out-file "rule_$i.json" -enc  ascii
            $i += 1
        }
    }
    finally {
        Pop-Location
    }
}