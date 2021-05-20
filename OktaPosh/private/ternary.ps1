function ternary {
    param (
        [Parameter(Mandatory)]
        $value,
        [Parameter(Mandatory)]
        $ifTrue,
        [Parameter(Mandatory)]
        $ifFalse
    )

    if ($value) { $ifTrue } else { $ifFalse }
}
