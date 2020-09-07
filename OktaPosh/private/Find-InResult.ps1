function Find-InResult {
    param (
        $Result,
        [string] $Query
    )
    if ($Result -and $Query) {
        $Result | Where-Object name -like "*$Query*"
    } else {
        $Result
    }
}