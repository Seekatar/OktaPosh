function Build-OktaSpaApplication {
    param (
        [Parameter(Mandatory)]
        [string] $Label,
        [Parameter(Mandatory)]
        [string[]] $RedirectUris,
        [Parameter(Mandatory)]
        [string] $LoginUri,
        [string[]] $PostLogoutUris,
        [switch] $Inactive,
        [string] $SignOnMode = "OPENID_CONNECT",
        [hashtable] $Properties,
        [ValidateCount(1,3)]
        [ValidateSet('implicit','authorization_code','refresh_token')]
        [string[]] $GrantTypes = @('implicit','refresh_token'),
        [Parameter(Mandatory)]
        [string] $AuthServerId,
        [string[]] $Scopes
    )

    Set-StrictMode -Version Latest
    $ErrorActionPreference = "Stop"

    $appName = $Label

    $app = Get-OktaApplication -Query $appName
    if ($app) {
        Write-Host "Found and updating app '$($app.label)' $($app.id)"
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
                    -Inactive:$Inactive `
                    -SignOnMode $SignOnMode `
                    -Properties $Properties `
                    -GrantTypes $GrantTypes
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
    if ($Scopes) {
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
    }
    return $app
}

if (!(Test-Path alias:Build-OktaSpaApp)) {
    New-Alias -Name Build-OktaSpaApp -Value Build-OktaSpaApplication
}
