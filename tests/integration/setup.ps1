if (!$env:OKTA_API_TOKEN) {
    Write-Error "Missing `$env:OKTA_API_TOKEN"
}
if (!$env:OKTA_BASE_URI) {
    Write-Error "Missing `$env:OKTA_BASE_URI"
}
Import-Module (Join-Path $PSScriptRoot ../../src/OktaPosh.psd1) -Force
