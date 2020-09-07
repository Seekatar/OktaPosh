<#
.SYNOPSIS
Apply a query in the case when Okta doesn't have one

.PARAMETER Result
Result from Okta

.PARAMETER Query
The query to use to search on the name
#>
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