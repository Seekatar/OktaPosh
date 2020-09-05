if (!$env:oktaApiToken) {
    Write-Error "Missing `$env:oktaApiToken"
}
if (!$env:oktaBaseUri) {
    Write-Error "Missing `$env:oktaBaseUri"
}