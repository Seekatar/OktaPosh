BeforeAll {
    . (Join-Path $PSScriptRoot '../setup.ps1') -Unit
}

# Pester 5 need to pass in TestCases object to pass share
$PSDefaultParameterValues = @{
    "It:TestCases" = @{ ipdId = "0oa3mo3swhHpQbzOw4u7" }
}

Describe "Identity Provider" {
    It "Gets Identity Providers" {
        $null = Get-OktaIdentityProvider
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/idps" -and $Method -eq 'GET'
                }
    }
    It "Gets an Identity Provider By Id" {
        $null = Get-OktaIdentityProvider -Id $ipdId
        $null = Get-OktaIdentityProvider -Query $ipdId
        Should -Invoke Invoke-WebRequest -Times 2 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/idps?$ipdId" -and $Method -eq 'GET'
                }
    }
    It "Gets an Identity Provider by Query" {
        $null = Get-OktaIdentityProvider -Query test
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/idps?q=test" -and $Method -eq 'GET'
                }
    }
}

