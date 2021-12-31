function normalizeClaimType($ClaimType) {
    if ($ClaimType -eq "ACCESS_TOKEN") {
        return "RESOURCE"
    } elseif ($ClaimType -eq "ID_TOKEN") {
        return "IDENTITY"
    } else {
        return $ClaimType
    }
}
