BeforeAll {
    . (Join-Path $PSScriptRoot '../setup.ps1') -Unit
}

# Pester 5 need to pass in TestCases object to pass share
$PSDefaultParameterValues = @{
    "It:TestCases" = @{ variables = @{
                            cluster = "nonprod"
                            domainSuffix = "-dev"
                            additionalRedirect = "http://localhost:8009/my-ui/implicit/callback"
                            groupNames = "groupNames.json"
                            groupObjects = "groups.json"
                        }
                      }
}

Describe "Cleanup" {
}
Describe "DumpConfig" {
    It "tests ui-and-app variables" {
        $config = Import-OktaConfiguration -JsonConfig ../samples/import/ui-and-app.json -Variables $variables -DumpConfig
        $config | Should -Be (Get-Content ./export/ui-and-app-config.json -Raw)
    }
    It "tests ui-and-app variables" {
        $config = Import-OktaConfiguration -JsonConfig ../samples/import/ui-app.json -Variables $variables -DumpConfig
        $config | Should -Be (Get-Content ./export/ui-app-config.json -Raw)
    }
}

Describe "Cleanup" {
}

