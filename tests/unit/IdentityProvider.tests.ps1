BeforeAll {
    . (Join-Path $PSScriptRoot '../setup.ps1') -Unit
}

# Pester 5 need to pass in TestCases object to pass share
$PSDefaultParameterValues = @{
    "It:TestCases" = @{ ipdId = "123-123-345" }
}

Describe "Identity Provider" {
    It "Gets Identity Providers" {
        $null = Get-OktaIdentityProvider
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/idps" -and $Method -eq 'GET'
                }
    }
    It "Gets an Identity Provider" {
        $null = Get-OktaIdentityProvider -Id $ipdId
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/idps?$ipdId" -and $Method -eq 'GET'
                }
    }
}

