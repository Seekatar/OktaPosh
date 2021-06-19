BeforeAll {
    . (Join-Path $PSScriptRoot '../setup.ps1') -Unit
}

# Pester 5 need to pass in TestCases object to pass share
$PSDefaultParameterValues = @{
    "It:TestCases" = @{ policyName = "test-policy"
                        vars = @{policy = @{id = "123-123-345";name="test";description="test"}
                                 rule = @{id = "123-123-345";name="test"}
                        } }
}

Describe "Cleanup" {
    It "Remove test policy" {
    }
}
Describe "Policy" {
    It "Adds a password policy" {
        $params = @{
            Name = $policyName
            Description = $policyName
            Priority = 4
            RecoveryQuestionStatus = "INACTIVE"
        }
        $null = New-OktaPasswordPolicy @params
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/policies" -and $Method -eq 'POST'
                }
    }
    It "Adds a password policy rule" {
        $null = New-OktaPasswordPolicyRule -PolicyId $vars.policy.id -Name $policyName `
                                            -AllowPasswordChange `
                                            -AllowSelfServicePasswordReset `
                                            -AllowSelfServiceUnlock
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/policies/$($vars.policy.id)/rules" -and $Method -eq 'POST'
                }
    }
    It "Gets Password Policy Rules" {
        $null = @(Get-OktaPolicyRule -PolicyId $vars.policy.id)
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/policies/$($vars.policy.id)/rules" -and $Method -eq 'GET'
                }
    }
    It "Gets Password Policy Rule by Id" {
        $null = Get-OktaPolicyRule -PolicyId $vars.policy.id -RuleId $vars.rule.id
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/policies/$($vars.policy.id)/rules/$($vars.rule.id)" -and $Method -eq 'GET'
                }
    }
    It "Gets Password Policies" {
        $null = @(Get-OktaPasswordPolicy -Type PASSWORD)
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/policies?type=PASSWORD" -and $Method -eq 'GET'
                }
    }
    It "Gets Password Policy By Id" {
        $null = Get-OktaPasswordPolicy -Id $vars.policy.Id
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/policies/$($vars.policy.Id)" -and $Method -eq 'GET'
                }
    }
    It "Gets Password Policy By Id with rules" {
        $null = Get-OktaPasswordPolicy -Id $vars.policy.Id -WithRules
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/policies/$($vars.policy.Id)?expand=rules" -and $Method -eq 'GET'
                }
    }
    It "Disable Password Policy Rule" {
        $null = Disable-OktaPasswordPolicyRule -PolicyId $vars.policy.Id -RuleId $vars.rule.Id
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/policies/$($vars.policy.Id)/rules/$($vars.rule.id)/lifecycle/deactivate" -and $Method -eq 'POST'
                }
    }
    It "Enable Password Policy" {
        $null = Enable-OktaPasswordPolicyRule -PolicyId $vars.policy.Id -RuleId $vars.rule.Id
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/policies/$($vars.policy.Id)/rules/$($vars.rule.id)/lifecycle/activate" -and $Method -eq 'POST'
                }
    }
    It "Disable Password Policy" {
        $null = Disable-OktaPasswordPolicy -Id $vars.policy.Id
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/policies/$($vars.policy.Id)/lifecycle/deactivate" -and $Method -eq 'POST'
                }
    }
    It "Enable Password Policy" {
        $null = Enable-OktaPasswordPolicy -Id $vars.policy.Id
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/policies/$($vars.policy.Id)/lifecycle/activate" -and $Method -eq 'POST'
                }
    }
    It "Updates Password Policy" {
        $null = Set-OktaPasswordPolicy -Policy $vars.policy
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/policies/$($vars.policy.Id)" -and $Method -eq 'PUT'
                }
    }

}

Describe "Cleanup" {
    It "Remove test policy" {
        Mock Get-OktaPasswordPolicy -ModuleName OktaPosh -MockWith { @{name=$policyName}}
        Mock Get-OktaPolicyRule -ModuleName OktaPosh -MockWith { @{name=$policyName}}

        Remove-OktaPolicyRule -PolicyId $vars.policy.id -RuleId $vars.rule.id -Confirm:$false
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/policies/$($vars.policy.Id)/rules/$($vars.rule.id)" -and $Method -eq 'DELETE'
                }

        Remove-OktaPasswordPolicy -PolicyId $vars.policy.id -Confirm:$false
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/policies/$($vars.policy.Id)" -and $Method -eq 'DELETE'
                }
    }
}

