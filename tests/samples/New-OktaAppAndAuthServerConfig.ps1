function New-OktaAppAndAuthServerConfig
{
    param(
        [Parameter(Mandatory)]
        [Hashtable] $AuthServer,
        [Parameter(Mandatory)]
        [Hashtable[]] $Applications,
        [Parameter(Mandatory)]
        [string[]] $GroupNames,
        [Parameter(Mandatory)]
        [string[]] $Origins,
        [ValidateSet("authorization_code", "password", "client_credentials", "implicit")]
        [string[]] $GrantTypes = @("authorization_code")
    )

    Set-StrictMode -Version Latest
    $ErrorActionPreference = "Stop"

    try {

        . (Join-Path $PSScriptRoot New-OktaAuthServerConfig.ps1)
        . (Join-Path $PSScriptRoot New-OktaAppConfig.ps1)

        $as = New-OktaAuthServerConfig -authServerName $AuthServer.authServerName `
                                -Scopes $AuthServer.scopes `
                                -audience $AuthServer.audience `
                                -description $AuthServer.description `
                                -claims $AuthServer.claims `
                                -GroupNames $GroupNames

        $groupPrefix = ($GroupNames[0] -split '-')[0..2] -Join '-'
        
        $existingGroups = @(Get-OktaGroup -q $groupPrefix)
        while (Test-OktaNext -ObjectName groups) { $existingGroups += Get-OktaGroup -Next; }
        if ($existingGroups) {
            $existingGroupNames = $existingGroups.profile.name
        } else {
            $existingGroupNames = @()
        }

        $groups = @($existingGroups | Where-Object { $_.profile.name -in $GroupNames })
        Write-Host "Found $($existingGroups.count) groups for $groupPrefix* and want $($GroupNames.Count) may add $($groups.Count)"
        $groupToAdd = $GroupNames | Where-Object { $_ -notin $existingGroupNames }
        foreach ($group in $groupToAdd) {
            $g = New-OktaGroup -Name $group
            Write-Host "Added group '$group'"
            $groups += $g
        }

        foreach ($newApp in $Applications) {
            $app = New-OktaAppConfig -Name $newApp.Name `
                            -Scopes $newApp.Scopes `
                            -RedirectUris $newApp.RedirectUris `
                            -LoginUri $newApp.LoginUri `
                            -PostLogoutUris $newApp.PostLogoutUris `
                            -GrantTypes $GrantTypes `
                            -AuthServerId $as.Id
            if (Get-Member -InputObject $app.credentials.oauthClient -Name client_secret ) {
                $newApp.client_secret = $app.credentials.oauthClient.client_secret
            }
            $newApp.client_id = $app.credentials.oauthClient.client_id
            $appGroupIds = @((Get-OktaApplicationGroup -AppId $app.id) | Select-Object -ExpandProperty id)
            while (Test-OktaNext -ObjectName "apps/$($app.id)/groups" ) { $appGroupIds += (Get-OktaApplicationGroup -AppId $app.id -Next).id }
            Write-Host "    Found $($appGroupIds.Count) existing groups on the app"

            foreach ($group in ($groups | Where-Object { $_.id -notin $appGroupIds})) {
                $null = Add-OktaApplicationGroup -AppId $app.id -GroupId $group.id
                Write-Host "    Added '$($group.profile.name)' group to app '$($app.label)'"
            }
        }

        foreach ($origin in $Origins) {
            if (Get-OktaTrustedOrigin -Filter "origin eq `"$origin`"") {
                Write-Host "Found origin '$origin'"
            } else {
                $null = New-OktaTrustedOrigin -Name $origin -Origin $origin -CORS -Redirect
                Write-Host "Added origin '$origin'"
            }
        }

    } catch {
        Write-Error "$_`n$($_.ScriptStackTrace)"
    }

    Write-Host @"

-----
Summary:
Auth server:
    id: $($as.Id)
    issuer: $($as.issuer)
"@

    $Applications | ForEach-Object {
    Write-Host @"
App: $($_.Name)
    Scopes: $($_.Scopes)
    client_id: $($_.client_id)
    `$userName = 'fflintstone@mailinator.com'
    `$pw = 'clearTextPw'
    `$scopes = 'openid','email','casualty.TestSPA.client.usaa'
    `$jwt = Get-OktaJwt -ClientId $($_.client_id) -Issuer $($as.issuer) -RedirectUri http://localhost:8008/fp-ui/implicit/callback -Username `$userName -Pw `$pw -Scopes `$scopes
"@
}

}