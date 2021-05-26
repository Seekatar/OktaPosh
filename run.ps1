param (
    [ValidateSet('unit','integration','build','analyze','new-help','update-help')]
    [string[]] $Task,
    [switch] $PesterPassThru
)

function checkPester
{
    $p = Get-Module Pester
    if (!$p -or $p.Version.Major -lt 5) {
        throw "Must have Pester 5 or higher installed to run tests. (Install-Module Pester -force)"
    }
}

foreach ($t in $Task) {

    try {
    $prevPref = $ErrorActionPreference
    $ErrorActionPreference = "Stop"

    switch ($t) {
        'unit' {
            checkPester
            Push-Location (Join-Path $PSScriptRoot '/tests/unit')
            Invoke-Pester -Configuration @{Output = @{Verbosity='Detailed'}; Run = @{PassThru=[bool]$PesterPassThru}; CodeCoverage=@{Enabled=$true;Path='../../OktaPosh/public/*.ps1'}}
        }
        'integration' {
            checkPester
            Push-Location (Join-Path $PSScriptRoot '/tests/integration')
            Invoke-Pester -Configuration @{Output = @{Verbosity='Detailed'}; Run = @{PassThru=[bool]$PesterPassThru}; CodeCoverage=@{Enabled=$true;Path='../../OktaPosh/public/*.ps1'}}
        }
        'build' {
            Push-Location (Join-Path $PSScriptRoot '/build')
            .\New-ModuleHelp.ps1
            if (Test-Path \code\joat-powershell\New-HelpOutput.ps1) {
                $Groups = "Authorization","Claim","User","Group","Policy","Rule","Scope","Application","TrustedOrigin","PasswordPolicy"
                \code\joat-powershell\New-HelpOutput.ps1 -Folder ..\OktaPosh\ -GroupPrefix "Okta" -Groups $groups | Out-File ..\summary.md -Encoding ascii
            } else {
                Write-Warning "\code\joat-powershell\New-HelpOutput.ps1 not found, won't update summary"
            }
            .\Update-Manifest.ps1
        }
        'analyze' {
            if (!(Get-Module PSScriptAnalyzer -ListAvailable)) {
                throw "Must install PSScript Analyzer (Install-Module -Name PSScriptAnalyzer)"
            }
            Push-Location (Join-Path $PSScriptRoot '/OktaPosh')
            Invoke-ScriptAnalyzer -Path . -Recurse
        }
        'new-help' {
            Push-Location $PSScriptRoot
            if(-not (Get-Module platyPS -ListAvailable)) {
                Install-Module platyPS -Scope CurrentUser -Force
            }
            Import-Module platyPS
            Import-Module ./OktaPosh/OktaPosh.psd1 -Force
            $dir = (Join-Path ([System.IO.Path]::GetTempPath()) oktaposhdocs)
            if (!(Test-Path $dir)) {
                New-Item $dir -ItemType Directory
            }
            Remove-Item $dir -Force -Confirm:$false -Recurse
            New-MarkdownHelp -Module OktaPosh -OutputFolder $dir -Force
            "Output in $dir"
        }
        'update-help' {
            Push-Location $PSScriptRoot
            if(-not (Get-Module platyPS -ListAvailable)) {
                Install-Module platyPS -Scope CurrentUser -Force
            }
            Import-Module platyPS
            Import-Module ./OktaPosh/OktaPosh.psd1 -Force
            Update-MarkdownHelp .\docs -UpdateInputOutput:$false
        }
        Default {}
    }

    } finally {
        Pop-Location
        $ErrorActionPreference = $prevPref
    }
}