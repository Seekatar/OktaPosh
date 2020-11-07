BeforeAll {
    . (Join-Path $PSScriptRoot '../setup.ps1')
}

# Pester 5 need to pass in TestCases object to pass share
$PSDefaultParameterValues = @{
    "It:TestCases" = @{ ipdId = "123-123-345" }
}

Describe "Identity Provider" {
    It "Gets Identity Providers" {
        $result = Get-OktaIdentityProvider
        $result | Should -Be $null
    }
    It "Gets an Identity Provider" {
        $result = Get-OktaIdentityProvider -Id $ipdId
        $result | Should -Be $null
    }
}

