BeforeAll {
    . (Join-Path $PSScriptRoot '../setup.ps1')
    Mock -CommandName Start-Process `
        -ModuleName OktaPosh
        # -MockWith {
        # }
}

# Pester 5 need to pass in TestCases object to pass share
$PSDefaultParameterValues = @{
    "It:TestCases" = @{ groupName = "OktaPosh-test-misc"
                      }
}

Describe "Yaml tests" {
    It "ConvertTo-OktaYaml" {
        ConvertTo-OktaYaml -OutputFolder $env:TMP/oktaposh-yaml -WipeFolder -IncludeOkta -ApplicationQuery 'Okta'
        (Test-Path $env:TMP/oktaposh-yaml) | Should -BeTrue
        (Get-ChildItem $env:TMP/oktaposh-yaml/app-*).Count | Should -BeGreaterThan 1
        (Test-Path $env:TMP/oktaposh-yaml/trustedOrigins.yaml) | Should -BeTrue
    }
}

AfterAll {
    Remove-Item $env:TMP/oktaposh-yaml -Recurse -Force -ErrorAction Ignore
}
