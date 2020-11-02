<#
.SYNOPSIS
Set the function and alias exports in the manifest file
#>
[CmdletBinding()]
param(
)

    Push-Location (Join-Path $PSScriptRoot "../*/public")
    try {
        $publicFunctions = Select-String 'function\s+([\w-]*)' *.ps1 | ForEach-Object { $_.Matches.Groups[1].Value }
        $publicAliases = Select-String 'New-Alias\s+([\w-]*)' *.ps1 | ForEach-Object { $_.Matches.Groups[1].Value }
        $path = Get-ChildItem ../*.psd1
        Update-ModuleManifest -Path $path -FunctionsToExport $publicFunctions -AliasesToExport $publicAliases
        Get-Content $path | ForEach-Object { $_.TrimEnd() } | Out-File "$path.tmp"
        Copy-Item "$path.tmp" $path
        Remove-Item "$path.tmp"
        "Updated module with $($publicFunctions.Count) functions"
        if ($publicAliases) {
            "   and $($publicAliases.Count) aliases"
        }
    } catch {
        Write-Error "$_`n$($_.ScriptStackTrace)"
    } finally {
        Pop-Location
    }