$policies = Get-OktaPasswordPolicy -Type PASSWORD
$groups = (Get-OktaGroup -q CCC-Casualty-Pw-)

$name = "Casualty Policy - Others - Jim"
$hasRules = $false
$policy = $policies | ? name -eq $name
if (!$policy) {
    $parms = @{
        Name = $name
        Description = $name
        Priority = 4
        RecoveryQuestionStatus = "INACTIVE"
        IncludeGroups = ($groups | ? { $_.profile.name -notlike 'CCC-Casualty-Pw-USAA*'}).id
    }
    $policy = New-OktaPasswordPolicy @parms
    $policy
    "Added policy $Name"
} else {
    "Found policy '$Name' Id = $($policy.id)"
    $hasRules = (Get-OktaPolicy -Id $policy.id -WithRules)._embedded.rules.count
}
if (!$hasRules) {
    New-OktaPasswordPolicyRule -PolicyId $policy.id -Name $Name -AllowPasswordChange -AllowSelfServicePasswordReset -AllowSelfServiceUnlock
    "Add rule to policy $Name"
} else {
    "Policy $Name has rules"
}

$name = "Casualty USAA Policy Only. - Jim"
$hasRules = $false
$policy = $policies | ? name -eq $name
if (!$policy) {
    $parms = @{
        Name = $Name
        Description = $Name
        ExcludeUserName = $true
        ExcludeDictionaryCommon = $true
        ExcludeAttributes = @('firstName','lastName')
        MaxAgeDays = 90
        MinAgeMinutes = 7200
        Priority = 3
        RecoveryQuestionStatus = "INACTIVE"
        IncludeGroups = ($groups | ? { $_.profile.name -like 'CCC-Casualty-Pw-USAA*'}).id
    }
    $policy = New-OktaPasswordPolicy @parms
    $policy
    "Added policy $Name"
} else {
    "Found policy '$Name' Id = $($policy.id)"
    $hasRules = (Get-OktaPolicy -Id $policy.id -WithRules)._embedded.rules.count
}
if (!$hasRules) {
    New-OktaPasswordPolicyRule -PolicyId $policy.id -Name $Name -AllowPasswordChange -AllowSelfServicePasswordReset -AllowSelfServiceUnlock
    "Add rule to policy $Name"
} else {
    "Policy $Name has rules"
}
