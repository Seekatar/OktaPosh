function ternary {
    param (
        [bool] $value,
        $ifTrue,
        $ifFalse
    )

    if ($value) { $ifTrue } else { $ifFalse }
}
