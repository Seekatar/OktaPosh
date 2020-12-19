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
        [string[]] $Origins
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
                                -claims $AuthServer.claims

        $groups = @()
        foreach ($group in $GroupNames) {
            $g = Get-OktaGroup -Query $group
            if ($g) {
                Write-Host "Found group '$group'"
            } else {
                $g = New-OktaGroup -Name $group
                Write-Host "Added group '$group'"
            }
            $groups += $g
        }


        foreach ($newApp in $Applications) {
            $app = New-OktaAppConfig -Name $newApp.Name `
                            -Scopes $newApp.Scopes `
                            -RedirectUris $newApp.RedirectUris `
                            -LoginUri $newApp.LoginUri `
                            -PostLogoutUris $newApp.PostLogoutUris `
                            -GrantTypes "authorization_code", "password", "client_credentials", "implicit" `
                            -AuthServerId $as.Id
            foreach ($group in $groups) {
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

}