function arraysEqual {
    param (
        [object[]] $left,
        [object[]] $right
    )
    if ($left -and $right) {
        if ($left.Count -eq $right.Count) {
            foreach ($l in $left) {
                if ($l -notin $right) {
                    return $false
                }
            }
            return $true
        } else {
            return $false
        }
    }
    return !($left -xor $right) # return true if both empty
}
