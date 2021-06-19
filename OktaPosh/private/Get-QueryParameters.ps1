function Get-QueryParameters {
    param (
        [Alias('Query')]
        [string] $Q,
        [uint32] $Limit,
        [string] $Filter,
        [string] $Search,
        [string] $SortBy,
        [string] $SortOrder
    )
    $params = @()
    foreach ($p in $PSBoundParameters.Keys) {
        if ($PSBoundParameters[$p]) {
            $params += "$($p.ToLower())=$([System.Web.HttpUtility]::UrlEncode($PSBoundParameters[$p]))"
        }
    }
    if ($params) {
        return "?$($params -join '&')"
    } else {
        return ''
    }
}
