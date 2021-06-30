BeforeAll {
    . (Join-Path $PSScriptRoot '../setup.ps1')
    Mock -CommandName Start-Process `
        -ModuleName OktaPosh
        # -MockWith {
        # }
}

# Pester 5 need to pass in TestCases object to pass share
$PSDefaultParameterValues = @{
    "It:TestCases" = @{ groupName = "test-misc"
                      }
}

Describe "Yaml tests" {
    It "Tests Get-OktaLog" {
        ConvertTo-OktaYaml -OutputFolder $env:TMP/oktaposh-yaml -WipeFolder
        (Test-Path $env:TMP/oktaposh-yaml) | Should -BeTrue
        (Get-ChildItem $env:TMP/oktaposh-yaml/app-*).Count | Should -BeGreaterThan 1
        (Test-Path $env:TMP/oktaposh-yaml/trustedOrigins.yaml) | Should -BeTrue
    }
    It "CleansUp" {
        Remove-Item $env:TMP/oktaposh-yaml -Recurse -Force -ErrorAction Ignore
    }
}