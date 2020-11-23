BeforeAll {
    . (Join-Path $PSScriptRoot '../setup.ps1')
}

$PSDefaultParameterValues = @{
    "It:TestCases" = @{ ipdId = "123-123-345" }
}

Describe "Identity Provider" {
    It "Gets Identity Providers" {
        $null = Get-OktaIdentityProvider
        # Currently a Google provider is there for my server
        # $result | Should -Not -Be $null
    }
    It "Gets Identity Provider By Id" {
        $result = Get-OktaIdentityProvider -Id $ipdId
        $result | Should -Be $null
    }
}

