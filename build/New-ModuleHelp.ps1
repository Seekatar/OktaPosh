# mainly from https://raw.githubusercontent.com/darquewarrior/vsteam/master/.docs/gen-help.ps1
[CmdletBinding()]
param(
    [string] $DocsSource = (Convert-Path "$PSScriptRoot\..\docs"),
    [string] $DocsOutput = "$PSScriptRoot\..\docs-generated",
    [string] $SourceFolder = (Convert-Path "$PSScriptRoot\..\src"),
    [switch] $SeparateSynopsis
)
Set-StrictMode -Version Latest
Write-Output 'Clearing old files'
Write-Verbose "$DocsSource => $DocsOutput => $SourceFolder/en-US"

if ((Test-Path $DocsOutput) -eq $false) {
   $null = New-Item -ItemType Directory -Path $DocsOutput
}
$DocsOutput = Convert-Path $DocsOutput

Get-ChildItem $DocsOutput | Remove-Item

Write-Output 'Creating file index'

$sb = New-Object System.Text.StringBuilder
$files = Get-ChildItem -Path $DocsSource -Filter '*-*.md'
Write-Verbose "Files is $DocsSource $files"
Write-Verbose "Found $($files.Count) files"

Push-Location $DocsSource 
try {
foreach ($file in $files) {
   $null = $sb.Append("### [$($file.BaseName)]($($file.Name))`r`n`r`n")
   if ($SeparateSynopsis) {
      $null = $sb.Append("<!-- #include ""./synopsis/$($file.Name)"" -->`r`n`r`n")
   }

   # I found files where the name of the file did not match the top most
   # title in the file. This will cause issues trying to load help for that
   # function. So test that you can find # {FileName} in the file.
   $stringToFind = "# $($file.BaseName)"
   Write-Verbose "Looking for $($file.Name)"
   if($null -eq $(Get-ChildItem $file.Name | Select-String $stringToFind)) {
      Write-Error "Title cannot be found in $($file.Name). Make sure the first header is # $($file.BaseName)`n$($File.Directory)\$File" -ErrorAction Stop
   }
}
} finally {
   Pop-Location
}

Set-Content -Path $DocsSource/files.md -Value $sb.ToString()

Write-Output 'Merging Markdown files'
if(-not (Get-Module Trackyon.Markdown -ListAvailable)) {
   Install-Module Trackyon.Markdown -Scope CurrentUser -Force
}

merge-markdown $DocsSource $DocsOutput

Write-Output 'Creating new file'

if(-not (Get-Module platyPS -ListAvailable)) {
   Install-Module platyPS -Scope CurrentUser -Force
}

$null = New-ExternalHelp $DocsOutput -OutputPath $SourceFolder/en-US -Force

# Run again and strip header
Write-Output 'Cleaning doc files for publishing'
Get-ChildItem $DocsOutput | Remove-Item
Rename-Item -Path $DocsSource\common\header.md -NewName header.txt
Set-Content -Path $DocsSource\common\header.md -Value ''

# Docs now don't have headers
merge-markdown $DocsSource $DocsOutput

# Put header back
Remove-Item $DocsSource\common\header.md
Rename-Item -Path $DocsSource\common\header.txt -NewName header.md -Force