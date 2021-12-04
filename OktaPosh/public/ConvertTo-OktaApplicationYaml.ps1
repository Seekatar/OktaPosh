
function ConvertTo-OktaApplicationYaml
{
    [CmdletBinding()]
    param (
        [Parameter(Position=0)]
        [string] $Query,
        [Parameter(Mandatory)]
        [ValidateScript({Test-Path $_ -PathType Container})]
        [string] $OutputFolder
    )
    Set-StrictMode -Version Latest
    $nl = [System.Environment]::NewLine

    $params = @{}
    if ($Query) {
        $params["q"] = $Query
    }
    $apps = Get-OktaApplication @params
    while (Test-OktaNext -ObjectName apps) { $appGroups += Get-OktaApplication -Next }

    Write-Verbose "Getting groups"
    $groups = @(Get-OktaGroup -limit 100)
    while (Test-OktaNext -ObjectName groups) { $groups += Get-OktaGroup -Next }

    foreach ($app in $apps | Sort-Object label) {
    $output = @"
label: $($app.label)
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
        $output += "${nl}groups:$nl"

        Write-Verbose "Getting appGroups"
        $appGroups = @(Get-OktaApplicationGroup -AppId $app.id -Limit 100)
        while (Test-OktaNext -ObjectName groups) { $appGroups += Get-OktaApplicationGroup -AppId $app.id -Next }

        Write-Verbose "Writing output for $($appGroups.Count) groups"
        $groupNames = @()
        $appGroups | ForEach-Object {
                $appGroupId = $_.id
                $group = ($groups | Where-Object { $_.id -eq $appGroupId } )
                if ($group) {
                    $group.profile.name | ForEach-Object {
                        $groupNames += "  - $_$nl"
                    }
                }
            }
        $output += $groupNames | Sort-Object
        $output | Out-File (Join-Path $OutputFolder "app-$($app.label).yaml") -Encoding ascii
        Write-Information (Join-Path $OutputFolder "app-$($app.label).yaml") -InformationAction Continue
    }
    Write-Verbose "Done"
}