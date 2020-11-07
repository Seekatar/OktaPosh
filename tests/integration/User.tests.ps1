. (Join-Path $PSScriptRoot '../setup.ps1')

# Pester 5 need to pass in TestCases object to pass share
$PSDefaultParameterValues = @{
    "It:TestCases" = @{
                        email = 'testuser@mailinator.com'
                        vars = @{user =$null} }
}

Describe "Cleanup" {
    It "Remove test user" {
        (Get-OktaUser -q $email) | Remove-OktaUser -Confirm:$false
    }
}

Describe "User" {
    It "Adds a user" {
        $vars.user = New-OktaUser -FirstName test-user -LastName test-user -Email $email
        $vars.user | Should -Not -Be $null
    }

    It "Gets Users" {
        $result = @(Get-OktaUser)
        $result | Should -Not -Be $null
        $result.Count | Should -BeGreaterThan 0
    }
    It "Tests Next" {
        Test-OktaNext -ObjectName users | Should -Be $false
        (Get-OktaNextUrl).Keys.Count | Should -Be 0
    }
    It "Tests RateLimit" {
        (Get-OktaRateLimit).RateLimit | Should -Be $null
    }
    It "Gets User By Email" {
        $result = Get-OktaUser -Query $email
        $result | Should -Not -Be $null
        $result.Profile.Email | Should -Be $email
    }
    It "Gets User By Id" {
        $result = Get-OktaUser -Id $vars.user.Id
        $result | Should -Not -Be $null
        $result.Id | Should -Be  $vars.user.Id
    }
    It "Adds AuthProviderUser" {
        $result = New-OktaAuthProviderUser -FirstName "fn" -LastName "ln" -Email "test-user@mailinator.com" -ProviderType SOCIAL
        $result | Should -Not -Be $null
        $result.status | Should -Be 'PROVISIONED'

        Remove-OktaUser -UserId $result.Id
    }
}

Describe "Cleanup" {
    It "Remove test user" {
        Remove-OktaUser -UserId $vars.user.id -Confirm:$false
    }
}

