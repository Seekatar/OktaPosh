BeforeAll {
    . (Join-Path $PSScriptRoot '../setup.ps1')
}

# Pester 5 need to pass in TestCases object to pass share
$PSDefaultParameterValues = @{
    "It:TestCases" = @{ policyName = "test-policy"
                        vars = @{policy = $null
                                 rule = $null
                        } }
}

Describe "Cleanup" {
    It "Remove test policy" {
        $existing = Get-OktaPasswordPolicy -Type PASSWORD | Where-Object name -eq $policyName
        if ($existing) {
            Remove-OktaPasswordPolicy -PolicyId $existing.Id -Confirm:$false
        }
    }
}
Describe "Policy" {
    It "Adds a password policy" {
        $params = @{
            Name = $policyName
            Description = $policyName
            Priority = 4
            # RecoveryQuestionStatus = "INACTIVE"
        }
        $vars.policy = New-OktaPasswordPolicy @params
        $vars.policy | Should -Not -BeNullOrEmpty
        $vars.policy.Name | Should -Be $policyName
    }
    It "Adds a password policy rule" {
        $vars.rule = New-OktaPasswordPolicyRule -PolicyId $vars.policy.id -Name $policyName `
                                            -AllowPasswordChange `
                                            -AllowSelfServicePasswordReset `
                                            -AllowSelfServiceUnlock
        $vars.rule | Should -Not -BeNullOrEmpty
        $vars.rule.Name | Should -Be $policyName
    }
    It "Gets Password Policy Rules" {
        $rule = @(Get-OktaPolicyRule -PolicyId $vars.policy.id)
        $rule | Should -Not -BeNullOrEmpty
        $rule.Count | Should -BeGreaterThan 0
    }
    It "Gets Password Policy Rule by Id" {
        $rule = Get-OktaPolicyRule -PolicyId $vars.policy.id -RuleId $vars.rule.id
        $rule | Should -Not -BeNullOrEmpty
        $rule.id | Should -Be $vars.rule.id
    }
    It "Gets Password Policies" {
        $policies = @(Get-OktaPasswordPolicy -Type PASSWORD)
        $policies | Should -Not -BeNullOrEmpty
        $policies.Count | Should -BeGreaterThan 0
        $policies | Where-Object id -eq $vars.policy.id | Should -Not -BeNullOrEmpty
    }
    It "Gets Password Policy By Id" {
        $policy = Get-OktaPasswordPolicy -Id $vars.policy.Id
        $policy | Should -Not -BeNullOrEmpty
        $policy.id | Should -Be $vars.policy.id
    }
    It "Gets Password Policy By Id with rules" {
        $policy = Get-OktaPasswordPolicy -Id $vars.policy.Id -WithRules
        $policy | Should -Not -BeNullOrEmpty
        $policy.id | Should -Be $vars.policy.id
        $policy._embedded.rules | Should -Not -BeNullOrEmpty
    }
    It "Disable Password Policy Rule" {
        Disable-OktaPolicyRule -PolicyId $vars.policy.Id -RuleId $vars.rule.id
    }
    It "Enable Password Policy Rule" {
        Enable-OktaPolicyRule -PolicyId $vars.policy.Id -RuleId $vars.rule.id
    }
    It "Disable Password Policy" {
        Disable-OktaPasswordPolicy -Id $vars.policy.Id
    }
    It "Enable Password Policy" {
        Enable-OktaPasswordPolicy -Id $vars.policy.Id
    }
    It "Updates Password Policy" {
        $vars.policy.description = 'new description'
        $policy = Set-OktaPasswordPolicy -Policy $vars.policy
        $policy.description | Should -Be $vars.policy.description
    }

}

Describe "Cleanup" {
    It "Remove test policy" {
        if ($vars.rule) {
            Remove-OktaPolicyRule -PolicyId $vars.policy.id -RuleId $vars.rule.id -Confirm:$false
        }

        if ($vars.policy) {
            Remove-OktaPasswordPolicy -PolicyId $vars.policy.id -Confirm:$false
        }
    }
}

