BeforeAll {
    . (Join-Path $PSScriptRoot '../setup.ps1') -Unit
}

# Pester 5 need to pass in TestCases object to pass share
$PSDefaultParameterValues = @{
    "It:TestCases" = @{ variables = @{
                            cluster = "OktaPosh"
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
    It "tests ui-and-server-app variables" {
        $config = Import-OktaConfiguration -JsonConfig ../samples/import/ui-and-server-app.json -Variables $variables -DumpConfig
        $config | Should -Be (Get-Content ./export/ui-and-server-app.json -Raw)
    }
    It "tests ui-app variables" {
        $config = Import-OktaConfiguration -JsonConfig ../samples/import/ui-app.json -Variables $variables -DumpConfig
        $config | Should -Be (Get-Content ./export/ui-app.json -Raw)
    }
    It "tests server-app variables" {
        $config = Import-OktaConfiguration -JsonConfig ../samples/import/server-app.json -Variables $variables -DumpConfig
        $config | Should -Be (Get-Content ./export/server-app.json -Raw)
    }
    It "tests file-replacement variables" {
        $config = Import-OktaConfiguration -JsonConfig ../samples/import/many-groups-ui-app.json -Variables $variables -DumpConfig
        $config | Should -Be (Get-Content ./export/many-groups-ui-app.json -Raw)
    }
    It "tests missing variable" {
        $badVariables = @{
            cluster = "nonprod"
        }
        $error.Clear()
        try {
            $null = Import-OktaConfiguration -JsonConfig ../samples/import/ui-app.json -Variables $badVariables -DumpConfig
            $false | Should -Be $true
        } catch {
            $error.Count | Should -Be 1
            $error[0] | Should -BeLike '*After variable replacement*'
        }

    }
}

Describe "Cleanup" {
}

