BeforeAll {
    . (Join-Path $PSScriptRoot '../setup.ps1')

    . (Join-Path $PSScriptRoot ../../OktaPosh/private/parseTime.ps1)
    . (Join-Path $PSScriptRoot ../../OktaPosh/private/ternary.ps1)

    Mock -CommandName Start-Process `
        -ModuleName OktaPosh
        # -MockWith {
        # }
}

# Pester 5 need to pass in TestCases object to pass share
$PSDefaultParameterValues = @{
    "It:TestCases" = @{ groupName = "OktaPosh-test-misc"
                        vars = @{
                            group = $null
                        }
                      }
}
$script:group = $null
$script:groupName = "OktaPosh-test-misc"

Describe "ReadOnly Tests" {
    It 'Gets and Sets ReadOnly' {
        Get-OktaReadOnly | Should -Be $false
        Set-OktaReadOnly
        Get-OktaReadOnly | Should -Be $true
        Set-OktaReadOnly $false
        Get-OktaReadOnly | Should -Be $false
    }
    It 'Tests Setting ReadOnly' {
        $script:group = New-OktaGroup -Name $groupName
        $script:group | Should -Be -Not $null
        Set-OktaReadOnly

        { New-OktaGroup -Name "$groupName-2" } | Should -Throw 'Set-OktaReadOnly is set. *'

        { Remove-OktaGroup -GroupId $script:group.id -Confirm:$false } | Should -Throw 'Set-OktaReadOnly is set. *'

        { Set-OktaGroup -Id $script:group.id -Name $groupName -Description "new description" } | Should -Throw 'Set-OktaReadOnly is set. *'
    }

    BeforeAll {
        Get-OktaGroup -Query $script:groupName | Remove-OktaGroup -Confirm:$false
    }

    AfterAll {
        Set-OktaReadOnly $false
        if ($script:group) {
            Remove-OktaGroup -GroupId $script:group.id -Confirm:$false
        }

    }
}

