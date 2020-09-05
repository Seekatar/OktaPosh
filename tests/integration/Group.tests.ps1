. (Join-Path $PSScriptRoot setup.ps1)

Describe "Group" {
    It "Gets Group" {
        $result = Get-OktaGroup
        $result | Should -Not -Be $null
        $result.Count | Should -BeGreaterThan 0
    }
}