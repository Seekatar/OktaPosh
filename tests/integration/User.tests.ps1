. (Join-Path $PSScriptRoot setup.ps1)

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
    }
}

