function ternary {
    param (
        [Parameter(Mandatory)]
        $value,
        $ifTrue,
        $ifFalse
    )

    if ($PSBoundParameters.Count -lt 3) {
        throw "Must supply 3 arguments, even if `$null"
    }
    if ($value) { $ifTrue } else { $ifFalse }
}
