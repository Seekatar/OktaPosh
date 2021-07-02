BeforeAll {
    . (Join-Path $PSScriptRoot '../setup.ps1')
}

$PSDefaultParameterValues = @{
    "It:TestCases" = @{ ipdId = "123-123-345" 
			vars = @{
				provider = $null
			}}
}

Describe "Identity Provider" {
    It "Gets Identity Providers" {
        $vars.provider = Get-OktaIdentityProvider | Select -First 1
        $vars.provider | Should -Not -Be $null
    }
    It "Gets Identity Provider By Id" {
        $result = Get-OktaIdentityProvider -Id $vars.provider.id
        $result.id | Should -Be $vars.provider.id 
        $result = Get-OktaIdentityProvider -Query $vars.provider.id
        $result.id | Should -Be $vars.provider.id 
    }
}

