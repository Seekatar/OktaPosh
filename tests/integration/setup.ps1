if (!$env:OKTA_API_TOKEN) {
    Write-Error "Missing `$env:OKTA_API_TOKEN"
}
if (!$env:OKTA_BASE_URI) {
    Write-Error "Missing `$env:OKTA_BASE_URI"
}
# functions use the env variables by default

Import-Module (Join-Path $PSScriptRoot ../../OktaPosh/OktaPosh.psd1) -Force
