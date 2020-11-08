param (
    [ValidateSet('unit','integration','build','new-help','update-help')]
    [string[]] $Task,
    [switch] $PesterPassThru
)

foreach ($t in $Task) {

    try {
    $prevPref = $ErrorActionPreference
    $ErrorActionPreference = "Stop"

    switch ($t) {
        'unit' {
            Push-Location (Join-Path $PSScriptRoot '/tests/unit')
            Invoke-Pester -Configuration @{Output = @{Verbosity='Detailed'}; Run = @{PassThru=[bool]$PesterPassThru}; CodeCoverage=@{Enabled=$true;Path='../../OktaPosh/public/*.ps1'}}
        }
        'integration' {
            Push-Location (Join-Path $PSScriptRoot '/tests/integration')
            Invoke-Pester -Configuration @{Output = @{Verbosity='Detailed'}; Run = @{PassThru=[bool]$PesterPassThru}; CodeCoverage=@{Enabled=$true;Path='../../OktaPosh/public/*.ps1'}}
        }
        'build' {
            Push-Location (Join-Path $PSScriptRoot '/build')
            .\New-ModuleHelp.ps1
            .\Update-Manifest.ps1
        }
        'new-help' {
            Push-Location $PSScriptRoot
            Import-Module platyPS
            Import-Module ./OktaPosh/OktaPosh.psd1 -Force
            $dir = (Join-Path $env:TEMP oktaposhdocs)
            if (!(Test-Path $dir)) {
                New-Item $dir -ItemType Directory
            }
            Remove-Item $dir -Force -Confirm:$false -Recurse
            New-MarkdownHelp -Module OktaPosh -OutputFolder $dir -Force
            "Output in $dir"
        }
        'update-help' {
            Push-Location $PSScriptRoot
            Import-Module platyPS
            Update-MarkdownHelp .\docs
        }
        Default {}
    }

    } finally {
        Pop-Location
        $ErrorActionPreference = $prevPref
    }
}