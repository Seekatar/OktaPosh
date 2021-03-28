function Show-Okta
{
    [CmdletBinding()]
    param(
        [string] $AuthorizationServerId,
        [string] $AppId
    )

    Set-StrictMode -Version Latest

    $uri = (Get-OktaBaseUri)
    if ($AuthorizationServerId) {
        $uri = $uri -replace "\.okta\.com","-admin.okta.com"
        $uri += "admin/oauth2/as/$AuthorizationServerId"
    } elseif ($AppId) {
        $uri = $uri -replace "\.okta\.com","-admin.okta.com"
        $uri += "admin/app/oidc_client/instance/$AppId/#tab-general"
    }
    Write-Verbose "Launching $uri"
    Start-Process -FilePath $uri

}