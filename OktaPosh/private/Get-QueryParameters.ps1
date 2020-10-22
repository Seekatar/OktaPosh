function Get-QueryParameters {
    param (
        [Alias('Query')]
        [string] $Q,
        [uint32] $Limit,
        [string] $After,
        [string] $Filter,
        [string] $Search
    )
    $parms = @()
    foreach ($p in $PSBoundParameters.Keys) {
        if ($PSBoundParameters[$p]) {
            $parms += "$($p.ToLower())=$([System.Web.HttpUtility]::UrlEncode($PSBoundParameters[$p]))"
        }
    }
    if ($parms) {
        return "?$($parms -join '&')"
    } else {
        return ''
    }
}
