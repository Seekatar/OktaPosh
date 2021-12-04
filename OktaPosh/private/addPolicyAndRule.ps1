
function addPolicyAndRule($policyName, $authServerId, $appId, $grantTypes, $scopes) {

    Set-StrictMode -Version Latest

    # create policies to restrict scopes per app
    if ($policyName) {
        $policy = Get-OktaPolicy -AuthorizationServerId $authServerId -Query $policyName
        if ($policy) {
            Write-Information "  Found policy '$($policyName)'"
        } else {
            $policy = New-OktaPolicy -AuthorizationServerId $authServerId `
                                     -Name $policyName `
                                     -ClientIds $appId
            Write-Information "  Added policy '$($policyName)'"
        }
        if (!$WhatIfPreference) {
            $rule = Get-OktaRule -AuthorizationServerId $authServerId `
                                -PolicyId $policy.id `
                                -Query "Allow $($policyName)"
        } else {
            $rule = $null
        }
        if ($rule) {
            Write-Information "  Found rule 'Allow $($policyName)'"
            if (!(arraysEqual $rule.conditions.scopes.include $scopes)) {
                $rule.conditions.scopes.include = $scopes
                $null = Set-OktaRule -AuthorizationServerId $authServerId `
                                     -PolicyId $policy.id `
                                     -Rule $rule
                Write-Information "  Updated rule's scopes"
            }
        } else {
            if (!$WhatIfPreference) {
                $rule = New-OktaRule -AuthorizationServerId $authServerId `
                                    -Name "Allow $($policyName)" `
                                    -PolicyId $policy.id `
                                    -Priority 1 `
                                    -GrantTypes $grantTypes `
                                    -Scopes $scopes
            }
            Write-Information "  Added rule 'Allow $($policyName)'"
        }
    }
}

