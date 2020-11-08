param (
    [ValidateSet('unit','integration','build')]
    [string] $Task
)

try {

switch ($Task) {
    'unit' {
        Push-Location (Join-Path $PSScriptRoot '/tests/unit')
        Invoke-Pester -Configuration @{Output = @{Verbosity='Detailed'}; Run = @{PassThru=$true}; CodeCoverage=@{Enabled=$true;Path='../../OktaPosh/public/*.ps1'}}
     }
     'integration' {
        Push-Location (Join-Path $PSScriptRoot '/tests/integration')
        Invoke-Pester -Configuration @{Output = @{Verbosity='Detailed'}; Run = @{PassThru=$true}; CodeCoverage=@{Enabled=$true;Path='../../OktaPosh/public/*.ps1'}}
     }
     'build' {
        Push-Location (Join-Path $PSScriptRoot '/build')
        .\New-ModuleHelp.ps1
        .\Update-Manifest.ps1
     }
    Default {}
}

} finally {
    Pop-Location
}
