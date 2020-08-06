param( [bool] $Quiet = $false )

Get-ChildItem $PSScriptRoot\src\private\*.ps1 | ForEach-Object { . $_ }
$exports = @()
Get-ChildItem $PSScriptRoot\src\public\*.ps1 | ForEach-Object { . $_; $exports += $_.BaseName }

Export-ModuleMember -Function '*' -Alias '*'

if (!$Quiet) {
    Write-Information "`nOktaPosh loaded. Use help <command> -Full for help.`n`nCommands:" -InformationAction Continue
    Write-Information (Get-Command -Module OktaPosh | Select-Object -ExpandProperty Name | Sort-Object | Out-String) -InformationAction Continue

    Write-Information "Aliases:" -InformationAction Continue
    Write-Information (Get-Alias *rel | Where-Object { $_.Source -eq 'OktaPosh' } | Select-Object -ExpandProperty DisplayName | Sort-Object | Out-string) -InformationAction Continue

    Write-Information "Use Import-Module OktaPost -ArgumentList `$true to suppress this message`n" -InformationAction Continue
}
