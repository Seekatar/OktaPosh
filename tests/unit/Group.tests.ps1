BeforeAll {
    . (Join-Path $PSScriptRoot '../setup.ps1') -Unit
}

# Pester 5 need to pass in TestCases object to pass share
$PSDefaultParameterValues = @{
    "It:TestCases" = @{ groupName = "test-group"
                        email = 'grouptestuser@mailinator.com'
                        vars = @{group = @{id = "00g3mo3swhHpQbzOw4u7";profile=@{description="test"}}
                                 user = @{id = "00u3mo3swhHpQbzOw4u7"}
                        } }
}

Describe "Cleanup" {
    It "Remove test group" {
    }
}
Describe "Group" {
    It "Adds a group" {
        $null = New-OktaGroup -Name $groupName
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/groups" -and $Method -eq 'POST'
                }
    }
    It "Gets Groups" {
        $null = @(Get-OktaGroup)
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/groups" -and $Method -eq 'GET'
                }
    }
    It "Gets Group By Name" {
        $null = Get-OktaGroup -Query $groupName
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/groups?q=$groupName" -and $Method -eq 'GET'
                }
    }
    It "Gets Group By Id" {
        $null = Get-OktaGroup -Id $vars.group.Id
        $null = Get-OktaGroup -Query $vars.group.Id
        Should -Invoke Invoke-WebRequest -Times 2 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/groups/$($vars.group.Id)" -and $Method -eq 'GET'
                }
    }
    It "Updates Group Separate params" {
        $null = Set-OktaGroup -Id $vars.group.Id -Name $groupName -Description "new description"
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/groups/$($vars.group.Id)" -and $Method -eq 'PUT'
                }
    }
    It "Updates Group object" {
        $vars.group.profile.description = "newer description"
        $null = Set-OktaGroup -Group $vars.group
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/groups/$($vars.group.Id)" -and $Method -eq 'PUT'
                }
    }
    It "Adds a user to a group and removes it" {
        $null = Add-OktaGroupUser -GroupId $vars.group.id -UserId $vars.user.id
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/groups/$($vars.group.Id)/users/$($vars.user.id)" -and $Method -eq 'PUT'
                }
        $null = Get-OktaGroupUser -GroupId $vars.group.id
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/groups/$($vars.group.Id)/users" -and $Method -eq 'GET'
                }

        $null = @(Get-OktaUserGroup -UserId $vars.user.id)
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*users/$($vars.user.id)/groups" -and $Method -eq 'GET'
                }

        Remove-OktaGroupUser -GroupId $vars.group.id -UserId $vars.user.id
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/groups/$($vars.group.Id)/users/$($vars.user.id)" -and $Method -eq 'DELETE'
                }
    }
}

Describe "Cleanup" {
    It "Remove test group" {
        Mock Get-OktaGroup -ModuleName OktaPosh -MockWith { @{profile=@{name='test'}}}
        Remove-OktaGroup -GroupId $vars.group.id -Confirm:$false
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/groups/$($vars.group.Id)" -and $Method -eq 'DELETE'
                }
    }
}

