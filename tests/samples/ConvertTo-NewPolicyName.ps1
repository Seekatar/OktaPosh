function ConvertTo-NewPolicyName
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateScript( { Test-Path $_ -PathType Container })]
        [string] $Folder
    )
    Set-StrictMode -Version Latest

    Get-ChildItem -r (Join-Path $Folder *.ps1) | ForEach-Object {
        $content = Get-Content $_ -raw
        $content = $content -replace '(New|Get|Remove|Set)-OktaRule', '$1-OktaAuthorizationServerRule'
        $content = $content -replace '(New|Get|Remove|Set)-OktaPolicy\b', '$1-OktaAuthorizationServerPolicy'

        $content = $content -replace 'Get-OktaPasswordPolicy', 'Get-OktaPolicy'
        $content = $content -replace 'Remove-OktaPasswordPolicy', 'Remove-OktaPolicy'
        $content = $content -replace 'Set-OktaPasswordPolicy', 'Set-OktaPolicy'

        $content | Out-File -FilePath $_ -Encoding ascii -NoNewline
    }
}