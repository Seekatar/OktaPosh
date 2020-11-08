BeforeAll {
    . (Join-Path $PSScriptRoot '../setup.ps1')
}

# Pester 5 need to pass in TestCases object to pass share
$PSDefaultParameterValues = @{
    "It:TestCases" = @{ TrustedOriginName = "http://github.com"
                        vars = @{
                            trustedOrigin = $null
                        }
                    }
}

Describe "TrustedOrigin" {
    It "Adds a TrustedOrigin" {
        $vars.trustedOrigin = New-OktatrustedOrigin -Name $trustedOriginName -Origin $trustedOriginName -CORS -Redirect
        $vars.trustedOrigin | Should -Not -Be $null
    }
    It "Gets TrustedOrigins" {
        $result = @(Get-OktatrustedOrigin)
        $result | Should -Not -Be $null
        $result.Count | Should -BeGreaterThan 0
    }
    It "Gets TrustedOrigin By Name" {
        $result = Get-OktatrustedOrigin -Filter "name eq `"$trustedOriginName`""
        $result | Should -Not -Be $null
        $result.Count | Should -BeGreaterThan 0
    }
    It "Gets TrustedOrigin By Id" {
        $result = Get-OktatrustedOrigin -Id $vars.trustedOrigin.Id
        $result | Should -Not -Be $null
        $result.Count | Should -BeGreaterThan 0
    }
    It "Updates TrustedOrigin object" {
        $vars.trustedOrigin.name = "NewName"
        $origin = Set-OktatrustedOrigin -trustedOrigin $vars.trustedOrigin
        $origin.name | Should -Be "NewName"
    }
}

Describe "Cleanup" {
    It "Remove test TrustedOrigin" {
        Remove-OktatrustedOrigin -trustedOriginId $vars.trustedOrigin.id -Confirm:$false
    }
}

