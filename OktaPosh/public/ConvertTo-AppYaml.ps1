function ConvertTo-AppYaml
{
    [CmdletBinding()]
    param (
        [string] $Query
    )

    $params = @{}
    if ($Query) {
        $params["q"] = $Query
    }
    $apps = Get-OktaApplication @params

    "applications:"
    foreach ($app in $apps | Sort-Object label) {
    @"
    - label: $($app.label)
      status: $($app.status)
      name: $($app.name)
"@
    }
}