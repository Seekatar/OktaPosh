$script:useQueryForId = $true

function testQueryForId( $appId, $query, $prefix ) {
    if ($appId) {
        return $appId
    } else {
        return ternary ($script:useQueryForId -and $query -and $query.Length -eq 20 -and $query.Substring(0,3) -eq $prefix) $query $null
    }
}

