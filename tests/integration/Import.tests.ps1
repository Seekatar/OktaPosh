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

function cleanUp {
    Get-OktaAuthorizationServer -Query OktaPosh-OktaPosh-test-AS | Remove-OktaAuthorizationServer -Confirm:$false
    Get-OktaApplication -Query 'OktaPosh-test-*' | Remove-OktaApplication -Confirm:$false
    Get-OktaGroup -Query 'OktaPosh-test-*' | Remove-OktaGroup -Confirm:$false
    Get-OktaTrustedOrigin -Query 'OktaPosh-test-*' | Remove-OktaTrustedOrigin -Confirm:$false
}

BeforeEach {
    cleanUp
}

AfterEach {
    cleanUp
}

# DumpConfig tests would be identical
Describe "DumpConfig" {
    It "tests ui-and-server-app variables" {
        Import-OktaConfiguration -JsonConfig ../samples/import/ui-and-server-app.json -Variables $variables
        $config | Should -Be (Get-Content ./export/ui-and-server-app-config.json -Raw)
    }
    It "tests ui-app variables" {
        $config = Import-OktaConfiguration -JsonConfig ../samples/import/ui-app.json -Variables $variables -DumpConfig
        $config | Should -Be (Get-Content ./export/ui-app-config.json -Raw)
    }
    It "tests server-app variables" {
        $config = Import-OktaConfiguration -JsonConfig ../samples/import/server-app.json -Variables $variables -DumpConfig
        $config | Should -Be (Get-Content ./export/server-app-config.json -Raw)
    }
    It "tests file-replacement variables" {
        $config = Import-OktaConfiguration -JsonConfig ../samples/import/many-groups-ui-app.json -Variables $variables -DumpConfig
        $config | Should -Be (Get-Content ./export/many-groups-ui-app-config.json -Raw)
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

