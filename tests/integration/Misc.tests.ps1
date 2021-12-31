BeforeAll {
    . (Join-Path $PSScriptRoot '../setup.ps1')
    Mock -CommandName Start-Process `
        -ModuleName OktaPosh
        # -MockWith {
        # }
}

# Pester 5 need to pass in TestCases object to pass share
$PSDefaultParameterValues = @{
    "It:TestCases" = @{ groupName = "OktaPosh-test-misc"
                      }
}

Describe "Log tests" {
    It "Tests Get-OktaLog" {
        Get-OktaLog
    }
    It "Tests Get-OktaLog Errors" {
        Get-OktaLog -Severity ERROR
    }
    It "Tests Get-OktaLog Limit Warn" {
        Get-OktaLog -Severity WARN -Limit 7 -Since 10h -SortOrder DESCENDING
    }
}
