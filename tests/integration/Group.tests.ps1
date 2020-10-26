. (Join-Path $PSScriptRoot setup.ps1)

# Pester 5 need to pass in TestCases object to pass share
$PSDefaultParameterValues = @{
    "It:TestCases" = @{ groupName = "test-group"
                        vars = @{group =$null} }
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
}

Describe "Cleanup" {
    It "Remove test group" {
        Get-OktaGroup -Query $groupName |
            Remove-OktaGroup -Confirm:$false
    }
}

