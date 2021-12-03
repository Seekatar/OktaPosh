BeforeAll {
    . (Join-Path $PSScriptRoot '../setup.ps1')
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
    Get-OktaApplication -Query 'OktaPosh-test-' | Remove-OktaApplication -Confirm:$false
    Get-OktaGroup -Query 'OktaPosh-test-' | Remove-OktaGroup -Confirm:$false
    Get-OktaTrustedOrigin | Where-Object origin -like '*.OktaPosh.*' | Remove-OktaTrustedOrigin -Confirm:$false
}


# DumpConfig tests would be identical
Describe "Imports Configuration" {
    BeforeEach {
        cleanUp
    }

    AfterEach {
        cleanUp
    }

    It "tests ui-and-server-app" {
        Import-OktaConfiguration -JsonConfig ../samples/import/ui-and-server-app.json -Variables $variables
        ConvertTo-OktaYaml -OutputFolder $env:TMP/oktaposh-yaml `
                           -AuthServerQuery OktaPosh-test `
                           -ApplicationQuery OktaPosh-test `
                           -OriginLike *.OktaPosh.* `
                           -GroupQueries OktaPosh-test `
                           -WipeFolder
        (Test-Path $env:TMP/oktaposh-yaml) | Should -BeTrue
        (Get-ChildItem $env:TMP/oktaposh-yaml/app-*).Count | Should -BeGreaterThan 1
        (Test-Path $env:TMP/oktaposh-yaml/trustedOrigins.yaml) | Should -BeTrue
        $folder = Join-Path $PSScriptRoot "export/ui-and-server-app"
        foreach ($file in Get-ChildItem -r "$env:TMP/oktaposh-yaml/*.yaml") {
            $testFile = $file.FullName.Replace("$env:TMP/oktaposh-yaml",$folder)
            Get-Content $file -Raw | Should -Be (Get-Content $testFile -Raw)
        }
    }
}

AfterAll {
    Remove-Item $env:TMP/oktaposh-yaml -Recurse -Force -ErrorAction Ignore
}
