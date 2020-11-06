param( [bool] $Quiet = $true )

if ($PSVersionTable.PSVersion.Major -lt 7) {
    Add-Type -AssemblyName System.Web
}

Get-ChildItem $PSScriptRoot\private\*.ps1 -Recurse | ForEach-Object { . $_ }
$exports = @()
Get-ChildItem $PSScriptRoot\public\*.ps1 -Recurse | ForEach-Object { . $_; $exports += $_.BaseName }

Export-ModuleMember -Function '*' -Alias '*'

if (!$Quiet) {
    Write-Information "`nOktaPosh loaded. Use help <command> -Full for help.`n`nCommands:" -InformationAction Continue
    Write-Information (Get-Command -Module OktaPosh | Select-Object -ExpandProperty Name | Sort-Object | Out-String) -InformationAction Continue

    Write-Information "Use Import-Module OktaPost -ArgumentList `$true to suppress this message`n" -InformationAction Continue
}
