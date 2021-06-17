
function ConvertTo-OktaApplicationYaml
{
    [CmdletBinding()]
    param (
        [string] $Query
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

    Write-Verbose "Getttng groups"
    $groups = @(Get-OktaGroup -limit 100)
    while (Test-OktaNext -ObjectName groups) { $groups += Get-OktaGroup -Next }

    "applications:"
    foreach ($app in $apps | Sort-Object label) {
    @"
    - label: $($app.label)
      status: $($app.status)
      name: $($app.name)
      settings:
        oauthClient:
          redirectUris: $(($app.settings.oauthClient.redirect_uris | Sort-Object)-join ', ')
          post_logout_redirect_uris: $(((getProp $app.settings.oauthClient 'post_logout_redirect_uris') | Sort-Object) -join ', ')
          grant_types: $(($app.settings.oauthClient?.grant_types | Sort-Object) -join ', ')
          response_types: $(($app.settings.oauthClient?.response_types | Sort-Object) -join ', ')
          initiate_login_uri: $((getProp $app.settings.oauthClient 'initiate_login_uri'))
          application_type: $($app.settings.oauthClient?.application_type)
          consent_method: $($app.settings.oauthClient?.consent_method)
      groups:
"@
        Write-Verbose "Gettting appGroups"
        $appGroups = Get-OktaApplicationGroup -AppId $app.id -Limit 1000
        while (Test-OktaNext -ObjectName groups) { $appGroups += Get-OktaApplicationGroup -AppId $app.id -Next }

        Write-Verbose "Writing output"
        $appGroups | ForEach-Object { ($groups | Where-Object id -eq $_.id).profile.name } | Sort-Object | ForEach-Object {
@"
      - $_
"@
        }
        Write-Verbose "Done"

    }
}