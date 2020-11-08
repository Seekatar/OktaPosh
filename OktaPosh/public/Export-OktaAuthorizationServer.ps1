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
        if ($PSVersionTable.PSVersion.Major -ge 7) {
            $encoding = [System.Text.Encoding]::ASCII
        } else {
            $encoding = "ascii"
        }
        Get-OktaAuthorizationServer -AuthorizationServerId $AuthorizationServerId -Json | Out-File auth.json -Encoding $encoding
        Join-Path $PWD "auth.json"
        $i = 1
        Get-OktaClaim -AuthorizationServerId $AuthorizationServerId -Json | ForEach-Object {
            $_ | ConvertTo-Json -Depth 10 | out-file "claim_$i.json" -enc $encoding
            Join-Path $PWD "claim_$i.json"
            $i += 1
        }
        $i = 1
        Get-OktaScope -AuthorizationServerId $AuthorizationServerId -Json | ForEach-Object {
            $_ | ConvertTo-Json -Depth 10 | out-file "scope_$i.json" -enc $encoding
            Join-Path $PWD "scope_$i.json"
            $i += 1
        }
        $i = 1
        Get-OktaPolicy -AuthorizationServerId $AuthorizationServerId | ForEach-Object {
            $_ | ConvertTo-Json -Depth 10 | out-file "policy_$i.json" -enc $encoding
            Join-Path $PWD "policy_$i.json"
            $i += 1
            $j = 1
            Get-OktaRule -AuthorizationServerId $AuthorizationServerId -PolicyId $_.id -Json | ForEach-Object {
                $_ | ConvertTo-Json -Depth 10 | out-file "rule_${i}_$j.json" -enc $encoding
                Join-Path $PWD "rule_${i}_$j.json"
                $i += 1
            }
        }
    }
    finally {
        Pop-Location
    }
}