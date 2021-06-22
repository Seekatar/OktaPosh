
function ConvertTo-OktaTrustedOriginYaml
{
    [CmdletBinding()]
    param (
        [string] $OriginLike = '*'
    )
    Set-StrictMode -Version Latest

    $tos = Get-OktaTrustedOrigin
    while (Test-OktaNext -ObjectName trustedOrigins) { $tos += Get-OktaTrustedOrigin -Next }

    "trustedOrigins:"
    foreach ($to in $tos | Where-Object origin -like $OriginLike | Sort-Object label) {
    @"
  - name: $($to.name)
    origin: $($to.origin)
    status: $($to.status)
    scopes:
      type:
"@
        foreach ($type in $to.scopes.type) {
            "        - $type"
        }
    }

}