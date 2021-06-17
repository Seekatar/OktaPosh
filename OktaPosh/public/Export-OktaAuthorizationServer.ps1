<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.PARAMETER AuthorizationServerId
Parameter description

.PARAMETER OutputFolder
Parameter description

.EXAMPLE
$auths = Get-OktaAuthorizationServer -q 'Casualty-' | ? name -like 'Casualty-*'
mkdir \oktadev
$auths | % { Export-OktaAuthorizationServer $_.id -output "\temp\oktadev\$($_.name)" }

Export all the casualty auth servers to folders

.NOTES
General notes
#>
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
        $params = @{}
        $params['Depth'] = 10

        try {

            if ($PSVersionTable.PSVersion.Major -ge 7) {
                $encoding = [System.Text.Encoding]::ASCII
            } else {
                $encoding = "ascii"
            }
            $auth = Get-OktaAuthorizationServer -AuthorizationServerId $AuthorizationServerId | ConvertTo-Json @params
            if (!$auth) {
                throw "Auth server not found for '$AuthorizationServerId'"
            }
            $auth | Out-File authorizationServer.json -Encoding $encoding
            Join-Path $PWD "authorizationServer.json"

            Get-OktaClaim -AuthorizationServerId $AuthorizationServerId | ConvertTo-Json @params | out-file "claims.json" -enc $encoding
            Join-Path $PWD "claims.json"

            Get-OktaScope -AuthorizationServerId $AuthorizationServerId | ConvertTo-Json @params | out-file "scopes.json" -enc $encoding
            Join-Path $PWD "scopes.json"

            $policies = @(Get-OktaPolicy -AuthorizationServerId $AuthorizationServerId)
            $policies | ConvertTo-Json @params | Out-File "policies.json" -enc $encoding
            Join-Path $PWD "policies.json"

            if ($policies) {
                $policies | ForEach-Object {
                    $policyName = $_.name
                    $rules = Get-OktaRule -AuthorizationServerId $AuthorizationServerId -PolicyId $_.id
                    if ($rules) {
                        $rules | ConvertTo-Json @params | out-file "rules_$policyName.json" -enc $encoding
                    }
                    Join-Path $PWD "rules_$policyName.json"
                }
            }
        } catch {
            Write-Error "$_`n$($_.ScriptStackTrace)"
        } finally {
            Pop-Location
        }
    }
}