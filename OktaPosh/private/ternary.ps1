function ternary {
    param (
        $value,
        $ifTrue,
        $ifFalse
    )

    if ($value) { $ifTrue } else { $ifFalse }
}
