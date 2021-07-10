function ternary {
    if ($args.Count -eq 2) {
        if ($args[0]) { $args[0] } else { $args[1] }
    } elseif ($args.Count -eq 3) {
        if ($args[0]) { $args[1] } else { $args[2] }
    } else {
        throw "Must supply 2 or 3 arguments to ternary, even if `$null"
    }
}
