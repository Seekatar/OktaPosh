function Build-OktaSpaApplication {
    param (
        [Parameter(Mandatory)]
        [string] $Label,
        [Parameter(Mandatory)]
        [string[]] $RedirectUris,
        [Parameter(Mandatory)]
        [string] $LoginUri,
        [string[]] $PostLogoutUris,
        [ObsoleteAttribute("Always active on add")]
        [switch] $Inactive,
        [string] $SignOnMode = "OPENID_CONNECT",
        [hashtable] $Properties,
        [ValidateCount(1,3)]
        [ValidateSet('implicit','authorization_code','refresh_token')]
        [string[]] $GrantTypes = @('implicit','refresh_token'),
        [Parameter(Mandatory)]
        [string] $AuthServerId,
        [string[]] $Scopes,
        [switch] $Quiet
    )

    Set-StrictMode -Version Latest
    $ErrorActionPreference = "Stop"

    $prevInformationPreference = $InformationPreference
    $InformationPreference = ternary $Quiet "SilentlyContinue" "Continue"
    try {

    $appName = $Label

    $app = Get-OktaApplication -Query $appName | Where-Object { $_ -and ($_.label -eq $appName) }
    if ($app) {
        Write-Information "Found and updating app '$($app.label)' $($app.id)"
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
                    -PostLogoutUris $PostLogoutUris `
                    -SignOnMode $SignOnMode `
                    -Properties $Properties `
                    -GrantTypes $GrantTypes
        Write-Information "Added app '$appName' $($app.id)"
    }

    addPolicyAndRule "$($app.Label)-Policy" $AuthServerId $app.id $GrantTypes $scopes

    return $app

} finally {
    $InformationPreference = $prevInformationPreference
}

}

if (!(Test-Path alias:Build-OktaSpaApp)) {
    New-Alias -Name Build-OktaSpaApp -Value Build-OktaSpaApplication
}
