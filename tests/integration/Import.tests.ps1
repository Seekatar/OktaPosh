BeforeAll {
    . (Join-Path $PSScriptRoot '../setup.ps1')
    function cleanUp($before) {
        Get-OktaAuthorizationServer -Query 'OktaPosh-test-' | Remove-OktaAuthorizationServer -Confirm:$false
        Get-OktaApplication -Query 'OktaPosh-test-' | Remove-OktaApplication -Confirm:$false
        Get-OktaGroup -Query 'OktaPosh-test-' | Remove-OktaGroup -Confirm:$false
        Get-OktaTrustedOrigin | Where-Object origin -like '*.OktaPosh.*' | Remove-OktaTrustedOrigin -Confirm:$false
    }
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


function testImportExport($fileName,$appCount) {
    Import-OktaConfiguration -JsonConfig "../samples/import/$fileName.json" -Variables $variables -Quiet

    ConvertTo-OktaYaml -OutputFolder $env:TMP/oktaPosh-yaml `
                       -AuthServerQuery OktaPosh-test `
                       -ApplicationQuery OktaPosh-test `
                       -OriginLike *.OktaPosh.* `
                       -GroupQueries OktaPosh-test `
                       -WipeFolder 3>$null

    (Test-Path $env:TMP/oktaPosh-yaml) | Should -BeTrue
    (@(Get-ChildItem $env:TMP/oktaPosh-yaml/app-*)).Count | Should -Be $appCount
    (Test-Path $env:TMP/oktaPosh-yaml/trustedOrigins.yaml) | Should -BeTrue
    $folder = Join-Path $PSScriptRoot "export/$fileName"
    foreach ($file in Get-ChildItem -r "$env:TMP/oktaPosh-yaml/*.yaml") {
        $testFile = $file.FullName -replace "$($env:TMP -replace '\\','.').oktaPosh-yaml",$folder
        # Write-Information "Checking $file vs $testFile"
        Get-Content $file -Raw | Should -Be (Get-Content $testFile -Raw)
    }
}

# DumpConfig tests would be identical
Describe "Imports Configuration" {
    BeforeEach {
        cleanUp $true
    }

    It "tests many-groups-ui-app" {
        testImportExport "many-groups-ui-app" 1
    }
    It "tests server-app" {
        testImportExport "server-app" 5
    }
    It "tests ui-and-server-app" {
        testImportExport "ui-and-server-app" 3
    }
    It "tests ui-app" {
        testImportExport "ui-app" 1
    }
}

AfterAll {
    cleanUp $false
    Remove-Item $env:TMP/oktaposh-yaml -Recurse -Force -ErrorAction Ignore
}
