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
