function Get-QueryParameters {
    param (
        [string] $Query,
        [uint32] $Limit,
        [string] $After
    )
    $parms = @()
    if ($Query) {
        $parms += = "q=$Query"
    }
    if ($Limit) {
        $parms += "limit=$limit"
    }
    if ($After) {
        $parms += "after=$after"
    }
    if ($parms) {
        return "?$($parms -join '&')"
    } else {
        return ''
    }
}
