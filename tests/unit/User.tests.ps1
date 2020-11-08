BeforeAll {
    . (Join-Path $PSScriptRoot '../setup.ps1') -Unit
}

# Pester 5 need to pass in TestCases object to pass share
$PSDefaultParameterValues = @{
    "It:TestCases" = @{
                        email = 'testuser@mailinator.com'
                        vars = @{user = @{id = '123-234'} }
    }
}

Describe "User" {
    It "Adds a user" {
        $null = New-OktaUser -FirstName test-user -LastName test-user -Email $email
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/users?activate=false" -and $Method -eq 'POST'
                }
    }
    It "Gets Users" {
        $null = @(Get-OktaUser)
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/users" -and $Method -eq 'GET'
                }
    }
    It "Tests Next" {
        Test-OktaNext -ObjectName users | Should -Be $false
        (Get-OktaNextUrl).Keys.Count | Should -Be 0
    }
    It "Tests RateLimit" {
        (Get-OktaRateLimit).RateLimit | Should -Be $null
    }
    It "Gets User By Email" {
        $null = Get-OktaUser -Query $email
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    # For PS5 uri is not encoded, PS7 it is
                    $Uri -like '*/users?q=testuser*mailinator.com' -and $Method -eq 'GET'
                }
    }
    It "Gets User By Id" {
        $null = Get-OktaUser -Id $vars.user.Id
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/users/$($vars.user.Id)" -and $Method -eq 'GET'
                }
    }
    It "Adds AuthProviderUser" {
        $null = New-OktaAuthProviderUser -FirstName "fn" -LastName "ln" -Email "test-user@mailinator.com" -ProviderType SOCIAL
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/users?provider=true" -and $Method -eq 'POST'
                }
    }
}

Describe "Cleanup" {
    It "Remove test user" {
        Mock Get-OktaUser -ModuleName OktaPosh -MockWith { @{profile=@{email='test'}}}
        Remove-OktaUser -UserId $vars.user.id -Confirm:$false
        Should -Invoke Invoke-WebRequest -Times 2 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/users/$($vars.user.Id)" -and $Method -eq 'DELETE'
                }
    }
}

