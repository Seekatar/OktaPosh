function Export-OktaAuthorizationServer {
    param (
        [Parameter(Mandatory)]
        [Alias("Id")]
        [string] $AuthorizationServerId,
        [Parameter(Mandatory)]
        [ValidateScript( { Test-Path $_ -PathType Container })]
        [string] $OutputFolder
    )

    Push-Location $OutputFolder
    try {
        $encoding = [System.Text.Encoding]::ASCII
        Get-OktaAuthorizationServer -AuthorizationServerId $AuthorizationServerId -Json | Out-File auth.json -Encoding $encoding
        Get-OktaClaim -AuthorizationServerId $AuthorizationServerId -Json | out-file claims.json -enc $encoding
        Get-OktaScope -AuthorizationServerId $AuthorizationServerId  -Json | out-file scope.json -enc $encoding
        $policy = Get-OktaPolicy -AuthorizationServerId $AuthorizationServerId
        $policy | ConvertTo-Json -Depth 10 | out-file policy.json -enc $encoding
        $policy | ForEach-Object {
            $i = 1
            Get-OktaRule -AuthorizationServerId $AuthorizationServerId -PolicyId $_.id -Json | out-file "rule_$i.json" -enc $encoding
            $i += 1
        }
    }
    finally {
        Pop-Location
    }
}