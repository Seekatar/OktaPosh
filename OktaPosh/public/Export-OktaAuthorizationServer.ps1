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
            $auth = Get-OktaAuthorizationServer -AuthorizationServerId $AuthorizationServerId -Json
            if (!$auth) {
                throw "Auth server not found for '$AuthorizationServerId'"
            }
            $auth | Out-File authorizationServer.json -Encoding $encoding
            Join-Path $PWD "authorizationServer.json"

            Get-OktaClaim -AuthorizationServerId $AuthorizationServerId -Json | out-file "claims.json" -enc $encoding
            Join-Path $PWD "claims.json"

            Get-OktaScope -AuthorizationServerId $AuthorizationServerId -Json | out-file "scopes.json" -enc $encoding
            Join-Path $PWD "scopes.json"

            $policies = Get-OktaPolicy -AuthorizationServerId $AuthorizationServerId -Json
            $policies | out-file "policies.json" -enc $encoding
            Join-Path $PWD "policies.json"

            $j = 1
            $temp = ConvertFrom-Json $policies # PS v5 quirk sends array through on next instead of each item, if don't use temp
            $temp | ForEach-Object { Get-OktaRule -AuthorizationServerId $AuthorizationServerId -PolicyId $_.id -Json } | ForEach-Object {
                $_ | out-file "rules_$j.json" -enc $encoding
                Join-Path $PWD "rules_$j.json"
                $j += 1
            }
        } catch {
            Write-Error "$_`n$($_.ScriptStackTrace)"
        } finally {
            Pop-Location
        }
    }
}