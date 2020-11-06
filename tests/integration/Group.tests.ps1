. (Join-Path $PSScriptRoot '../setup.ps1')

# Pester 5 need to pass in TestCases object to pass share
$PSDefaultParameterValues = @{
    "It:TestCases" = @{ groupName = "test-group"
                        email = 'grouptestuser@mailinator.com'
                        vars = @{group =$null
                                 user = $null
                        } }
}

Describe "Cleanup" {
    It "Remove test group" {
        (Get-OktaUser -q $email) | Remove-OktaUser -Confirm:$false
        (Get-OktaGroup -q $groupName) | Remove-OktaGroup -Confirm:$false
    }
}

Describe "Group" {
    It "Adds a group" {
        $vars.group = New-OktaGroup -Name $groupName
        $vars.group | Should -Not -Be $null
    }

    It "Gets Groups" {
        $result = @(Get-OktaGroup)
        $result | Should -Not -Be $null
        $result.Count | Should -BeGreaterThan 0
    }
    It "Gets Group By Name" {
        $result = Get-OktaGroup -Query $groupName
        $result.Profile.Name | Should -Be  $groupName
    }
    It "Gets Group By Id" {
        $result = Get-OktaGroup -Id $vars.group.Id
        $result.Id | Should -Be  $vars.group.Id
    }
    It "Updates Group Separate params" {
        $null = Set-OktaGroup -Id $vars.group.Id -Name $groupName -Description "new description"
        $vars.group = Get-OktaGroup -Id $vars.group.Id
        $vars.group.profile.description | Should -Be "new description"
    }
    It "Updates Group object" {
        $vars.group.profile.description = "newer description"
        $null = Set-OktaGroup -Group $vars.group
        $vars.group = Get-OktaGroup -Id $vars.group.Id
        $vars.group.profile.description | Should -Be "newer description"
    }
    It "Adds a user to a group and removes it" {
        $vars.user = New-OktaUser -FirstName test-user -LastName test-user -Email $email
        $vars.user | Should -Not -Be $null

        $null = Add-OktaGroupUser -GroupId $vars.group.id -UserId $vars.user.id
        $users = @(Get-OktaGroupUser -GroupId $vars.group.id)
        $users.Count | Should -Be 1

        Remove-OktaGroupUser -GroupId $vars.group.id -UserId $vars.user.id
        $users = Get-OktaGroupUser -GroupId $vars.group.id
        ($users -eq $null -or $users.Count -eq 0) | Should -Be $true
    }
}

Describe "Cleanup" {
    It "Remove test group" {
        if ($vars.user) {
            Remove-OktaUser -UserId $vars.user.id -Confirm:$false
        }
        if ($vars.group) {
            Remove-OktaGroup -GroupId $vars.group.id -Confirm:$false
        }
    }
}

