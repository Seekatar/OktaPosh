function New-OktaAppConfig {
    param (
        [Parameter(Mandatory)]
        [string] $Name,
        [Parameter(Mandatory)]
        [string[]] $RedirectUris,
        [Parameter(Mandatory)]
        [string] $LoginUri,
        [string[]] $PostLogoutUris,
        [Parameter(Mandatory)]
        [string[]] $Scopes,
        [Parameter(Mandatory)]
        [string] $AuthServerId,
        [Parameter(Mandatory)]
        [ValidateSet("authorization_code", "password", "refresh_token", "client_credentials", "implicit")]
        [string[]] $GrantTypes
    )

    Set-StrictMode -Version Latest
    $ErrorActionPreference = "Stop"

    $appName = $Name

    $app = Get-OktaApplication -Query $appName
    if ($app) {
        Write-Host "Found and updating app '$appName' $($app.id)"
        $app.settings.oauthClient.redirect_uris = $RedirectUris
        $app.settings.oauthClient.post_logout_redirect_uris = $PostLogoutUris
        $app.settings.oauthClient.grant_types = $GrantTypes
        $app.settings.oauthClient.initiate_login_uri = $LoginUri
        $app.settings.oauthClient.response_types = @()
        if ('implicit' -in $GrantTypes) {
            $app.settings.oauthClient.response_types += @('id_token', 'token')
        }
        if ('authorization_code' -in $GrantTypes) {
            $app.settings.oauthClient.response_types += 'code'
        }
        
        $app = Set-OktaApplication -Application $app
    } else {
        $app = New-OktaSpaApplication `
                    -Label $appName `
                    -RedirectUris $RedirectUris `
                    -LoginUri $LoginUri `
                    -PostLogoutUris $PostLogoutUris
        Write-Host "Added app '$appName' $($app.id)"
    }

    # create policies to restrict scopes per app
    $policyName = "$($app.Label)-Policy"
    $policy = Get-OktaPolicy -AuthorizationServerId $AuthServerId -Query $policyName
    if ($policy) {
        Write-Host "    Found '$($policyName)' Policy"
    } else {
        $policy = New-OktaPolicy -AuthorizationServerId $AuthServerId -Name $policyName -ClientIds $app.Id
        Write-Host "    Added '$($policyName)' Policy"
    }
    $rule = Get-OktaRule -AuthorizationServerId $AuthServerId -PolicyId $policy.id -Query "Allow $($policyName)"
    if ($rule) {
        Write-Host "    Found 'Allow $($policyName)' Rule"
    } else {
        $rule = New-OktaRule -AuthorizationServerId $AuthServerId `
                             -Name "Allow $($policyName)" `
                             -PolicyId $policy.id `
                             -Priority 1 `
                             -GrantTypes $GrantTypes `
                             -Scopes $Scopes
        Write-Host "    Added 'Allow $($policyName)' Rule"
    }
    return $app
}