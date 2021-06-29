function Set-QueryForId {
    param (
        [bool] $UseQueryForId
    )
    $script:useQueryForId = $UseQueryForId
}

function Get-QueryForId {
    $script:useQueryForId
}
