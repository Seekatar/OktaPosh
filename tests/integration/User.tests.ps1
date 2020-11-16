. (Join-Path $PSScriptRoot '../setup.ps1')

# Pester 5 need to pass in TestCases object to pass share
$PSDefaultParameterValues = @{
    "It:TestCases" = @{
                        email = 'testuser@mailinator.com'
                        email2 = 'testuser2@mailinator.com'
                        vars = @{
                            user = $null
                            user2 = $null
                            userCount = 0
                        }
                    }
}

Describe "Cleanup" {
    It "Remove test user" {
        (Get-OktaUser -q $email) | Remove-OktaUser -Confirm:$false
	    (Get-OktaUser -q $email2) | Remove-OktaUser -Confirm:$false
    }
}

Describe "User" {
    It "Adds a user" {
        $vars.user = New-OktaUser -FirstName test-user -LastName test-user -Email $email
        $vars.user | Should -Not -Be $null
    }
    It "Adds AuthProviderUser" {
        $vars.user2 = New-OktaAuthProviderUser -FirstName "fn" -LastName "ln" -Email $email2 -ProviderType SOCIAL
        $vars.user2 | Should -Not -Be $null
        $vars.user2.status | Should -Be 'PROVISIONED'
    }
    It "Gets Users" {
        $result = @(Get-OktaUser)
        $result | Should -Not -Be $null
        $result.Count | Should -BeGreaterThan 0
        $vars.userCount = $result.Count
    }
    It "Gets Next Users" {
        $users = @(Get-OktaUser -Limit ($vars.userCount - 1))
        $users.Count | Should -BeGreaterThan 0
        Test-OktaNext -ObjectName users | Should -Be $true
        $users = @(Get-OktaUser -Next)
        $users.Count | Should -BeGreaterThan 0
        Test-OktaNext -ObjectName users | Should -Be $false
        $users = @(Get-OktaUser -Next)
        $users | Should -Be $null
    }
    It "Tests Next" {
        Test-OktaNext -ObjectName users | Should -Be $false
        (Get-OktaNextUrl).Keys.Count | Should -Be 0
    }
    It "Tests RateLimit" {
        $limit = Get-OktaRateLimit
        $limit.RateLimit | Should -BeGreaterThan 0
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
}

Describe "Cleanup" {
    It "Remove test user" {
        Remove-OktaUser -UserId $vars.user.id -Confirm:$false
        Remove-OktaUser -UserId $vars.user2.id -Confirm:$false
    }
}

