
function ConvertTo-OktaTrustedOriginYaml
{
    [CmdletBinding()]
    param (
        [string] $Mask = '*'
    )
    Set-StrictMode -Version Latest

    function getProp( $object, $name )
    {
        if (Get-Member -InputObject $object -Name name) {
            $object.$name
        } else {
            $null
        }
    }
    $tos = Get-OktaTrustedOrigin | Where-Object origin -like $Mask

    "trustedOrigins:"
    foreach ($to in $tos | Sort-Object label) {
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