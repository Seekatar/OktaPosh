BeforeAll {
    . (Join-Path $PSScriptRoot '../setup.ps1')
}

# Pester 5 need to pass in TestCases object to pass share
$PSDefaultParameterValues = @{
    "It:TestCases" = @{
                        email = 'testuser@mailinator.com'
                        email2 = 'testuser2@mailinator.com'
                        email3 = 'testuser3@mailinator.com'
                        email4 = 'testuser4@mailinator.com'
                        email5 = 'testuser5@mailinator.com'
                        email6 = 'testuser6@mailinator.com'
                        vars = @{
                            user = $null
                            user2 = $null
                            user3 = $null
                            user4= $null
                            user5 = $null
                            user6 = $null
                            group = $null
                            userCount = 0
                        }
                    }
}

Describe "Cleanup" {
    It "Remove test user" {
        (Get-OktaUser -q $email) | Remove-OktaUser -Confirm:$false
	    (Get-OktaUser -q $email2) | Remove-OktaUser -Confirm:$false
	    (Get-OktaUser -q $email3) | Remove-OktaUser -Confirm:$false
	    (Get-OktaUser -q $email4) | Remove-OktaUser -Confirm:$false
	    (Get-OktaUser -q $email5) | Remove-OktaUser -Confirm:$false
	    (Get-OktaUser -q $email6) | Remove-OktaUser -Confirm:$false
        $vars.group = Get-OktaGroup -Query "userTestGroup"
        if (!$vars.group) {
            $vars.group = New-OktaGroup -Name "userTestGroup"
        }
    }
}

Describe "User" {
    It "Adds a user" {
        $vars.user = New-OktaUser -FirstName test-user -LastName test-user -Email $email
        $vars.user | Should -Not -Be $null
        $vars.user.Status | Should -Be 'STAGED'
    }
    It "Adds a user with recovery question" {
        $vars.user3 = New-OktaUser -FirstName test-user -LastName test-user -Email $email3 -RecoveryQuestion Why? -RecoveryAnswer "Answer is 42"
        $vars.user3 | Should -Not -Be $null
        $vars.user3.Status | Should -Be 'STAGED'
        $vars.user3.credentials.recovery_question.question | Should -Be 'Why?'
    }
    It "Adds a user to login next" {
        $vars.user4 = New-OktaUser -FirstName test-user -LastName test-user -Email $email4 -NextLogin -Activate -Pw "12SHiwS9876$%#"
        $vars.user4 | Should -Not -Be $null
        $vars.user4.Status | Should -Be 'PASSWORD_EXPIRED'
    }
    It "Adds a user to a group" {
        $vars.user5 = New-OktaUser -FirstName test-user -LastName test-user -Email $email5 -GroupIds @($vars.group.id)
        $vars.user5 | Should -Not -Be $null
        $vars.user5.Status | Should -Be 'STAGED'
        $groups = Get-OktaUserGroup -UserId $vars.user5.id
        $groups.id -contains $vars.group.id | Should -Be $true
    }
    It "Adds AuthProviderUser" {
        $vars.user2 = New-OktaAuthProviderUser -FirstName "fn" -LastName "ln" -Email $email2 -ProviderType FEDERATION -ProviderName FEDERATION -Activate
        $vars.user2 | Should -Not -Be $null
        $vars.user2.status | Should -Be 'ACTIVE'
    }
    It "Adds AuthProviderUser Activated" {
        $vars.user6 = New-OktaAuthProviderUser -FirstName "fn" -LastName "ln" -Email $email6 -ProviderType SOCIAL -Activate
        $vars.user6 | Should -Not -Be $null
        $vars.user6.status | Should -Be 'PROVISIONED'
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
        $users = @(Get-OktaUser -Next 3> $null)
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
        $result.Id | Should -Be $vars.user.Id
    }
    It "Updates a User" {
        $result = Get-OktaUser -Id $vars.user.Id
        $result | Should -Not -Be $null
        $result.profile.mobilePhone = '123-345'
        $newResult = Set-OktaUser $result
        $newResult.Id | Should -Be $vars.user.Id
        $newResult.profile.mobilePhone | Should -Be '123-345'
    }
    It "Activates a user" {
        $result = Enable-OktaUser -Id $vars.user.Id
        $result = Get-OktaUser -Id $vars.user.Id
        $result.Status | Should -Be 'PROVISIONED'
    }
    It "Suspends a user" {
        $result = Suspend-OktaUser -Id $vars.user.Id
        $result = Get-OktaUser -Id $vars.user.Id
        $result.Status | Should -Be 'SUSPENDED'
    }
    It "Resumes a user" {
        $result = Resume-OktaUser -Id $vars.user.Id
        $result = Get-OktaUser -Id $vars.user.Id
        $result.Status | Should -Be 'PROVISIONED'
    }
    It "Deactivates a user" {
        $result = Disable-OktaUser -Id $vars.user.Id
        $result = Get-OktaUser -Id $vars.user.Id
        $result.Status | Should -Be 'DEPROVISIONED'
    }
}

Describe "Cleanup" {
    It "Remove test user" {
        if ($vars.user) { Remove-OktaUser -UserId $vars.user.id -Confirm:$false }
        if ($vars.user2) { Remove-OktaUser -UserId $vars.user2.id -Confirm:$false }
        if ($vars.user3) { Remove-OktaUser -UserId $vars.user3.id -Confirm:$false }
        if ($vars.user4) { Remove-OktaUser -UserId $vars.user4.id -Confirm:$false }
        if ($vars.user5) { Remove-OktaUser -UserId $vars.user5.id -Confirm:$false }
        if ($vars.user6) { Remove-OktaUser -UserId $vars.user6.id -Confirm:$false }
        if ($vars.group) { Remove-OktaGroup -GroupId $vars.group.id -Confirm:$false }
    }
}

