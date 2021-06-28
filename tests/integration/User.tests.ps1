BeforeAll {
    . (Join-Path $PSScriptRoot '../setup.ps1')
}

# Pester 5 need to pass in TestCases object to pass share
$PSDefaultParameterValues = @{
    "It:TestCases" = @{
                        email1 = 'testuser1@mailinator.com'
                        email2 = 'testuser2@mailinator.com'
                        email3 = 'testuser3@mailinator.com'
                        email4 = 'testuser4@mailinator.com'
                        email5 = 'testuser5@mailinator.com'
                        email6 = 'testuser6@mailinator.com'
                        email7 = 'testuser7@mailinator.com'
                        primaryLink = "boss"
                        associatedLink = "minon"
                        vars = @{
                            user = $null
                            user2 = $null
                            user3 = $null
                            user4= $null
                            user5 = $null
                            user6 = $null
                            user7 = $null
                            group = $null
                            userCount = 0
                        }
                    }
}

Describe "Cleanup" {
    It "Remove test link definition" {
        Remove-OktaLinkDefinition -Name $primaryLink -Confirm:$false
    }
    It "Remove test user" {
        Get-OktaUser -q testuser | Remove-OktaUser -Confirm:$false
        $vars.group = Get-OktaGroup -Query "userTestGroup"
        if (!$vars.group) {
            $vars.group = New-OktaGroup -Name "userTestGroup"
        }
    }
}

Describe "User" {
    It "Adds a user" {
        $vars.user = New-OktaUser -FirstName test-user -LastName test-user -Email $email1
        $vars.user | Should -Not -Be $null
        $vars.user.Status | Should -Be 'STAGED'
    }
    It "Adds a with hashed pw" {
        $pw = "testing123"
        $salt = "this is the salt"
        $value = [System.Text.Encoding]::UTF8.GetBytes($pw)
        $saltValue = [System.Text.Encoding]::UTF8.GetBytes($salt)

        $saltedValue = $value + $saltValue

        $pwValue = (New-Object 'System.Security.Cryptography.SHA256Managed').ComputeHash($saltedValue)

        $passwordHash = @{
            hash = @{
              algorithm = "SHA-256"
              salt = ([System.Convert]::ToBase64String([System.Text.Encoding]::utf8.GetBytes($salt)))
              saltOrder = "POSTFIX"
              value = ([System.Convert]::ToBase64String($pwValue))
            }
          }

        $vars.user7 = New-OktaUser -Login $email7 -FirstName test-user -LastName test-user -Email $email7 -PasswordHash $passwordHash
        $vars.user7 | Should -Not -Be $null
        $vars.user7.Status | Should -Be 'STAGED'
    }
    It "Tries to use pw and has" {
        { New-OktaUser -Login $email1 -FirstName Test -LastName User -Email $email1 -PasswordHash @{} -Pw 'test' } | Should -Throw 'Can''t supply both*'
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
        $groups.id -contains $vars.group.id | Should -BeTrue

        $groups = @(Get-OktaUserGroup -UserId $vars.user5.id -limit 1) # in Everyone group, too so 2 groups
        $groups.Count | Should -Be 1
        Test-OktaNext "users/$($vars.user5.id)/groups" | Should -BeTrue
        $groups = @(Get-OktaUserGroup -UserId $vars.user5.id -next)
        $groups.Count | Should -Be 1
        Test-OktaNext "users/$($vars.user5.id)/groups" | Should -BeFalse
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
        $users.Count | Should -Be ($vars.userCount - 1)
        Test-OktaNext -ObjectName users | Should -BeTrue
        $users = @(Get-OktaUser -Next)
        $users.Count | Should -BeGreaterThan 0
        Test-OktaNext -ObjectName users | Should -BeFalse
        $users = @(Get-OktaUser -Next -NoWarn)
        $users | Should -Be $null

        Test-OktaNext -ObjectName users | Should -BeFalse
        (Get-OktaNextUrl).Keys.Count | Should -Be 0
    }
    It "Tests RateLimit" {
        $limit = Get-OktaRateLimit
        $limit.RateLimit | Should -BeGreaterThan 0
    }
    It "Gets User By Email" {
        $result = Get-OktaUser -Query $email1
        $result | Should -Not -Be $null
        $result.Profile.Email | Should -Be $email1
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

Describe "LinkTests" {
    It 'Creates a link definition' {
        $ld = New-OktaLinkDefinition -PrimaryTitle $primaryLink -AssociatedTitle $associatedLink
        $ld | Should -Not -BeNullOrEmpty
        $ld.primary.name | Should -Be $primaryLink
        $ld.associated.name | Should -Be $associatedLink
    }
    It 'Gets a link definition by primary' {
        $ld = Get-OktaLinkDefinition -Name $primaryLink
        $ld | Should -Not -BeNullOrEmpty
        $ld.primary.name | Should -Be $primaryLink
        $ld.associated.name | Should -Be $associatedLink
    }
    It 'Gets a link definition by associated' {
        $ld = Get-OktaLinkDefinition -Name $associatedLink
        $ld | Should -Not -BeNullOrEmpty
        $ld.primary.name | Should -Be $primaryLink
        $ld.associated.name | Should -Be $associatedLink
    }
    It 'Gets all link definitions' {
        $ld = @(Get-OktaLinkDefinition)
        $ld.Count | Should -BeGreaterThan 0
    }
    It 'Links two users to one' {
        $null = Set-OktaLink -PrimaryUserId $vars.user.id -AssociatedUserId $vars.user2.id -PrimaryName $primaryLink
        $null = Set-OktaLink -PrimaryUserId $vars.user.id -AssociatedUserId $vars.user3.id -PrimaryName $primaryLink
    }
    It 'Gets primary user link' {
        $ids = Get-OktaLink -UserId $vars.user.id -LinkName $associatedLink
        $ids | Should -Not -BeNullOrEmpty
        $ids.Count | Should -Be 2
        $ids | Where-Object { $_ -eq $vars.user2.id } | Should -Not -BeNullOrEmpty
        $ids | Where-Object { $_ -eq $vars.user3.id } | Should -Not -BeNullOrEmpty
    }
    It 'Gets primary user link as objects' {
        $ids = Get-OktaLink -UserId $vars.user.id -LinkName $associatedLink -GetUser
        $ids | Should -Not -BeNullOrEmpty
        $ids.Count | Should -Be 2
        $ids | Where-Object { $_.id -eq $vars.user2.id } | Should -Not -BeNullOrEmpty
        $ids | Where-Object { $_.id -eq $vars.user3.id } | Should -Not -BeNullOrEmpty
    }
    It 'Gets associate user link' {
        $ids = @(Get-OktaLink -UserId $vars.user2.id -LinkName $primaryLink)
        $ids | Should -Not -BeNullOrEmpty
        $ids.Count | Should -Be 1
        $ids | Should -Be $vars.user.id

        $ids = @(Get-OktaLink -UserId $vars.user3.id -LinkName $primaryLink)
        $ids | Should -Not -BeNullOrEmpty
        $ids.Count | Should -Be 1
        $ids | Should -Be $vars.user.id
    }
    It 'Removes a user link' {
        $null = Remove-OktaLink -UserId $vars.user2.id -PrimaryName $primaryLink -Confirm:$false
        $ids = @(Get-OktaLink -UserId $vars.user2.id -LinkName $primaryLink)
        $ids | Should -BeNullOrEmpty
    }
}

Describe "Cleanup" {
    It "Remove test link definition" {
        Remove-OktaLinkDefinition -Name $primaryLink -Confirm:$false
    }
    It "Remove test users" {
        if ($vars.user) { Remove-OktaUser -UserId $vars.user.id -Confirm:$false }
        if ($vars.user2) { Remove-OktaUser -UserId $vars.user2.id -Confirm:$false }
        if ($vars.user3) { Remove-OktaUser -UserId $vars.user3.id -Confirm:$false }
        if ($vars.user4) { Remove-OktaUser -UserId $vars.user4.id -Confirm:$false }
        if ($vars.user5) { Remove-OktaUser -UserId $vars.user5.id -Confirm:$false }
        if ($vars.user6) { Remove-OktaUser -UserId $vars.user6.id -Confirm:$false }
        if ($vars.user7) { Remove-OktaUser -UserId $vars.user7.id -Confirm:$false }
        if ($vars.group) { Remove-OktaGroup -GroupId $vars.group.id -Confirm:$false }
    }
}

