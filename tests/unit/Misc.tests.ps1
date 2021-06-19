BeforeAll {
    . (Join-Path $PSScriptRoot '../setup.ps1') -Unit
    Mock -CommandName Start-Process `
        -ModuleName OktaPosh
        # -MockWith {
        # }
}

# Pester 5 need to pass in TestCases object to pass share
$PSDefaultParameterValues = @{
    "It:TestCases" = @{ groupName = "test-misc"
                      }
}

Describe "Misc tests" {
    It "Tests Show-Okta" {
        Show-Okta
        Should -Invoke Start-Process -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $FilePath -eq (Get-OktaBaseUri)
                }
    }
    It "Tests Show-Okta AuthServer" {
        Show-Okta -AuthorizationServerId 123
        Should -Invoke Start-Process -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $FilePath -eq "$((Get-OktaBaseUri) -replace "\.okta\.com","-admin.okta.com")admin/oauth2/as/123"
                }
    }
    It "Tests Show-Okta AppId" {
        Show-Okta -AppId 123
        Should -Invoke Start-Process -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $FilePath -eq "$((Get-OktaBaseUri) -replace "\.okta\.com","-admin.okta.com")admin/app/oidc_client/instance/123/#tab-general"
                }
    }
}
Describe "Log tests" {
    It "Tests Get-OktaLog" {
        Get-OktaLog
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
            -ParameterFilter {
                $Uri -like "*/logs?limit=50&sortorder=ASCENDING&since=*" -and $Method -eq 'GET'
            }
    }
    It "Tests Get-OktaLog Errors" {
        Get-OktaLog -Severity ERROR
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
            -ParameterFilter {
                $Uri -like '*/logs?limit=50&sortorder=ASCENDING&filter=severity+eq+"ERROR"&since=*' -and $Method -eq 'GET'
            }
    }
    It "Tests Get-OktaLog Limit Warn" {
        Get-OktaLog -Severity WARN -Limit 7 -Since 10h -SortOrder DESCENDING
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
            -ParameterFilter {
                $Uri -like '*/logs?limit=7&sortorder=DESCENDING&filter=severity+eq+"WARN"&since=*' -and $Method -eq 'GET'
            }
    }
}
