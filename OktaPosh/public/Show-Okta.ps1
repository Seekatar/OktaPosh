function Show-Okta
{
    [CmdletBinding()]
    param()

    Set-StrictMode -Version Latest

    Start-Process (Get-OktaBaseUri)

}