BeforeAll {
    . (Join-Path $PSScriptRoot '../setup.ps1') -Unit

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
                        now = [DateTime]::UtcNow
                      }
}

Describe "ReadOnly Tests" {
    It 'Gets and Sets ReadOnly' {
        Get-OktaReadOnly | Should -Be $false
        Set-OktaReadOnly
        Get-OktaReadOnly | Should -Be $true
        Set-OktaReadOnly $false
        Get-OktaReadOnly | Should -Be $false
    }
    It 'Tests Setting ReadOnly' {
        $null = New-OktaGroup -Name $groupName
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/groups" -and $Method -eq 'POST'
                }
        Set-OktaReadOnly

        { New-OktaGroup -Name "$groupName-2" } | Should -Throw 'Set-OktaReadOnly is set. *'

        Mock Get-OktaGroup -ModuleName OktaPosh -MockWith { @{profile=@{name='test'}}}
        { Remove-OktaGroup -GroupId 123 -Confirm:$false } | Should -Throw 'Set-OktaReadOnly is set. *'

        { Set-OktaGroup -Id "123" -Name "$groupName-2" -Description "new description" } | Should -Throw 'Set-OktaReadOnly is set. *'
    }
}
