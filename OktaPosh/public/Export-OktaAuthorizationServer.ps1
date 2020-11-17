function Export-OktaAuthorizationServer {
    param (
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias("Id")]
        [string] $AuthorizationServerId,
        [Parameter(Mandatory)]
        [string] $OutputFolder
    )

    begin {
        if (!(Test-Path $OutputFolder -PathType Container)) {
            $null = mkdir $OutputFolder
            Write-Warning "Created '$OutputFolder'"
        }
        Push-Location $OutputFolder
    }

    process {
        if ($PSVersionTable.PSVersion.Major -ge 7) {
            $encoding = [System.Text.Encoding]::ASCII
        } else {
            $encoding = "ascii"
        }
        $auth = Get-OktaAuthorizationServer -AuthorizationServerId $AuthorizationServerId -Json
        if (!$auth) {
            throw "Auth server not found for '$AuthorizationServerId'"
        }
        $auth | Out-File auth.json -Encoding $encoding

        Join-Path $PWD "auth.json"
        $i = 1
        Get-OktaClaim -AuthorizationServerId $AuthorizationServerId -Json | ForEach-Object {
            $_ | out-file "claim_$i.json" -enc $encoding
            Join-Path $PWD "claim_$i.json"
            $i += 1
        }
        $i = 1
        Get-OktaScope -AuthorizationServerId $AuthorizationServerId -Json | ForEach-Object {
            $_ | out-file "scope_$i.json" -enc $encoding
            Join-Path $PWD "scope_$i.json"
            $i += 1
        }
        $i = 1
        Get-OktaPolicy -AuthorizationServerId $AuthorizationServerId -Json | ForEach-Object {
            $_ | out-file "policy_$i.json" -enc $encoding
            Join-Path $PWD "policy_$i.json"
            $j = 1
            Get-OktaRule -AuthorizationServerId $AuthorizationServerId -PolicyId $_.id -Json | ForEach-Object {
                $_ | out-file "rule_${i}_$j.json" -enc $encoding
                Join-Path $PWD "rule_${i}_$j.json"
                $j += 1
            }
            $i += 1
        }
    }

    end {
        Pop-Location
    }
}