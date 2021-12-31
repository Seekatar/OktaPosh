
function ConvertTo-OktaTrustedOriginYaml
{
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(ParameterSetName="Like",Position=0)]
        [string] $OriginLike = '*',
        [Parameter(ParameterSetName="Match",Mandatory,Position=0)]
        [string] $OriginMatch
    )
    Set-StrictMode -Version Latest

    $tos = Get-OktaTrustedOrigin
    while (Test-OktaNext -ObjectName trustedOrigins) { $tos += Get-OktaTrustedOrigin -Next }

    if ($OriginMatch) {
        $origins = $tos | Where-Object origin -match $OriginMatch
    } else {
        $origins = $tos | Where-Object origin -like $OriginLike
    }
    "trustedOrigins:"
    foreach ($to in $origins | Sort-Object name) {
    @"
  - name: $($to.name)
    origin: $($to.origin)
    status: $($to.status)
    scopes:
      type:
"@
        foreach ($type in $to.scopes.type | Sort-Object) {
            "        - $type"
        }
    }

}