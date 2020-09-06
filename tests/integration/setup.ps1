if (!$env:oktaApiToken) {
    Write-Error "Missing `$env:oktaApiToken"
}
if (!$env:oktaBaseUri) {
    Write-Error "Missing `$env:oktaBaseUri"
}
Import-Module (Join-Path $PSScriptRoot ../../src/OktaPosh.psd1) -Force
