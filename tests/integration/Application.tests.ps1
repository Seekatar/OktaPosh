BeforeAll {
    . (Join-Path $PSScriptRoot setup.ps1)
}

Describe "Application" {
    It "Gets Application" {
        $result = Get-OktaApplication
        $result | Should -Not -Be $null
        $result.Count | Should -BeGreaterThan 0
    }
}