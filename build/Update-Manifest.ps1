<#
.SYNOPSIS
Set the function and alias exports
#>
[CmdletBinding()]
param()

    Push-Location (Join-Path $PSScriptRoot ../src/public)
    try {
        $publicFunctions = Select-String 'function\s+([\w-]*)' *.ps1 | ForEach-Object { $_.Matches.Groups[1].Value }
        $publicAliases = Select-String 'New-Alias\s+([\w-]*)' *.ps1 | ForEach-Object { $_.Matches.Groups[1].Value }
        $path = Get-ChildItem ../*.psd1
        Update-ModuleManifest -Path $path -FunctionsToExport $publicFunctions -AliasesToExport $publicAliases
    } finally {
        Pop-Location
    }