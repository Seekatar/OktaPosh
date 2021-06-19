
function ConvertTo-OktaApplicationYaml
{
    [CmdletBinding()]
    param (
        [string] $Query,
        [Parameter(Mandatory)]
        [ValidateScript({Test-Path $_ -PathType Container})]
        [string] $OutputFolder
    )
    Set-StrictMode -Version Latest

    function getProp( $object, $name )
    {
        if (Get-Member -InputObject $object -Name $name) {
            $object.$name
        } else {
            $null
        }
    }
    $params = @{}
    if ($Query) {
        $params["q"] = $Query
    }
    $apps = Get-OktaApplication @params

    Write-Verbose "Getting groups"
    $groups = @(Get-OktaGroup -limit 100)
    while (Test-OktaNext -ObjectName groups) { $groups += Get-OktaGroup -Next }

    foreach ($app in $apps | Sort-Object label) {
    $output = @"
    - label: $($app.label)
      status: $($app.status)
      name: $($app.name)
      settings:
        oauthClient:
"@
    if (getProp $app.settings 'oauthClient') {
        $output += @"
          redirectUris: $(($app.settings.oauthClient.redirect_uris | Sort-Object) -join ', ')
          post_logout_redirect_uris: $(((getProp $app.settings.oauthClient 'post_logout_redirect_uris') | Sort-Object) -join ', ')
          grant_types: $(((ternary $app.settings.oauthClient $app.settings.oauthClient.grant_types '') | Sort-Object) -join ', ')
          response_types: $(((ternary $app.settings.oauthClient $app.settings.oauthClient.response_types '') | Sort-Object) -join ', ')
          initiate_login_uri: $(getProp $app.settings.oauthClient 'initiate_login_uri')
          application_type: $(ternary $app.settings.oauthClient $app.settings.oauthClient.application_type '')
          consent_method: $(ternary $app.settings.oauthClient $app.settings.oauthClient.consent_method '')
"@
        }
        $output += "`n      groups:`n"

        Write-Verbose "Getting appGroups"
        $appGroups = Get-OktaApplicationGroup -AppId $app.id -Limit 100
        while (Test-OktaNext -ObjectName groups) { $appGroups += Get-OktaApplicationGroup -AppId $app.id -Next }

        Write-Verbose "Writing output"
        $appGroups | ForEach-Object { ($groups | Where-Object id -eq $_.id).profile.name } | Sort-Object | ForEach-Object {
            $output += "      - $_`n"
        }
        $output | Out-File (Join-Path $OutputFolder "app-$($app.label).yaml") -Encoding ascii
        Write-Host (Join-Path $OutputFolder "app-$($app.label).yaml")
    }
    Write-Verbose "Done"
}