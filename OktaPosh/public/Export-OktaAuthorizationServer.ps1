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
            $null = New-Item $OutputFolder -ItemType Directory
            Write-Warning "Created output folder '$OutputFolder'"
        }
    }

    process {
        Set-StrictMode -Version Latest
        $ErrorActionPreference = "Stop"

        Push-Location $OutputFolder
        try {

            if ($PSVersionTable.PSVersion.Major -ge 7) {
                $encoding = [System.Text.Encoding]::ASCII
            } else {
                $encoding = "ascii"
            }
            $auth = Get-OktaAuthorizationServer -AuthorizationServerId $AuthorizationServerId
            if (!$auth) {
                throw "Auth server not found for '$AuthorizationServerId'"
            }
            $auth | ConvertTo-Json -Depth 5 | Out-File authorizationServer.json -Encoding $encoding
            Join-Path $PWD "authorizationServer.json"

            Get-OktaClaim -AuthorizationServerId $AuthorizationServerId | ConvertTo-Json -Depth 5 | Out-File "claims.json" -enc $encoding
            Join-Path $PWD "claims.json"

            Get-OktaScope -AuthorizationServerId $AuthorizationServerId | ConvertTo-Json -Depth 5 | Out-File "scopes.json" -enc $encoding
            Join-Path $PWD "scopes.json"

            $policies = Get-OktaPolicy -AuthorizationServerId $AuthorizationServerId
            $policies | ConvertTo-Json -Depth 5 | Out-File "policies.json" -enc $encoding
            Join-Path $PWD "policies.json"

            $j = 1
            $temp = $policies
            $temp | ForEach-Object { $script:policyName = $_.name; Get-OktaRule -AuthorizationServerId $AuthorizationServerId -PolicyId $_.id } | ForEach-Object {
                $_ | ConvertTo-Json -Depth 5 | Out-File "rules_${script:policyName}_$j.json" -enc $encoding
                Join-Path $PWD "rules_${script:policyName}_$j.json"
                $j += 1
            }
        } catch {
            Write-Error "$_`n$($_.ScriptStackTrace)"
        } finally {
            Pop-Location
        }
    }
}