BeforeAll {
    # . (Join-Path $PSScriptRoot setup.ps1)
}

# Pester 5 need to pass in TestCases object to pass share
$PSDefaultParameterValues = @{
    "It:TestCases" = @{
        appName    = "test-app"
        spaAppName = "test-spa-app"
        vars       = @{
            app    = $null
            spaApp = $null
            schema = $null
        }
    }
}

Describe "Application" {
    BeforeAll {
        Mock -CommandName Invoke-WebRequest `
            -MockWith {
            $Response = New-MockObject -Type  Microsoft.PowerShell.Commands.WebResponseObject
            $Content = '{"errorCode": "200" }'
            $StatusCode = 200

            $Response | Add-Member -NotePropertyName Content -NotePropertyValue $Content -Force
            $Response | Add-Member -NotePropertyName StatusCode -NotePropertyValue $StatusCode -Force
            $Response
        } `
            -ParameterFilter {
            $uri -match "api/v1/apps"
            $method -eq "post"
        } `
            -ModuleName OktaPosh
        #  -Verifiable `

        Mock Invoke-OktaApi
        # Mock -CommandName Invoke-WebRequest `
        #     -MockWith {
        #     return New-Object 'System.Net.Http.HttpResponseMessage' -ArgumentList 500
        # }`
        #     -ModuleName OktaPosh

        Mock Invoke-RestMethod { return @() } -ParameterFilter {
            $Uri -like "*_apis/projects*"
        }
    }

    # It "copied" {
    #     Invoke-RestMethod -Uri "http://junk/_apis/projects123"

    #     Should -Invoke Invoke-RestMethod -Exactly -Scope It -Times 1 -ParameterFilter {
    #         $Uri -like "*https://dev.azure.com/test/project/_apis/pipelines/24/runs*" -and
    #         $Uri -like "*api-version=$(_getApiVersion Build)*" -and
    #         $Body -like '*"PreviewRun":*true*' -and
    #         $Body -notlike '*YamlOverride*'
    #      }
    # }

    It "Adds a server application" {
        # Mock -CommandName Invoke-WebRequest `
        #     -MockWith {
        #         return @{
        #             StatusCode = 500
        #             Content = "{}"
        #         }
        #     } -Verifiable
        $vars.app = New-OktaServerApplication -Label $appName -Properties @{appName = $appName } -Verbose
        Should -Invoke Invoke-OktaApi -Times 1 -Exactly -Scope It `
                -ParameterFilter {
                    $RelativeUri -eq 'apps' -and $Method -eq "post"
                }
        # Assert-VerifiableMock

    }
    It "Adds a SPA application" {
        $vars.spaApp = New-OktaSpaApplication -Label $spaAppName -RedirectUris "http://gohome" -LoginUri "http://login"
        Should -Invoke Invoke-OktaApi -Times 1 -Exactly -Scope It `
        -ParameterFilter {
            $RelativeUri -eq 'apps' -and $Method -eq "post"
        }
    }
    # It "Gets Applications" {
    #     $result = Get-OktaApplication
    #     $result | Should -Not -Be $null
    #     $result.Count | Should -BeGreaterThan 0
    # }
    # It "Gets Application by Id" {
    #     $result = Get-OktaApplication -ApplicationId $vars.app.Id
    #     $result.Id | Should -Be $vars.app.Id
    # }
    # It "Disables Application" {
    #     Disable-OktaApplication -Id $vars.app.Id -Confirm:$false
    #     $result = Get-OktaApplication -ApplicationId $vars.app.Id
    #     $result.status | Should -Be 'INACTIVE'
    # }
    # It "Enables Application" {
    #     Enable-OktaApplication -Id $vars.app.Id
    #     $result = Get-OktaApplication -ApplicationId $vars.app.Id
    #     $result.status | Should -Be 'ACTIVE'
    # }
    # It "Set an Application" {
    #     $vars.spaApp.label = "test-updated"
    #     $result = Set-OktaApplication -Application $vars.spaApp
    #     $result.label | Should -Be $vars.spaApp.label
    # }
    # It "Sets profile property" {
    #     Set-OktaApplicationProperty -App $vars.app -Properties @{testProp = 'hi there' }
    #     $result = Get-OktaApplication -ApplicationId $vars.app.Id
    #     $result.profile.testProp | Should -Be 'hi there'
    # }

    # It "Adds Schema" {
    #     $vars.schema = Get-OktaApplicationSchema -AppId $vars.app.id
    #     $vars.schema | Should -Not -Be $null
    # }

    # It "Sets a schema value" {
    #     $schema = Set-OktaApplicationSchemaProperty -AppId $vars.app.id `
    #                                       -Name oktaPosh `
    #                                       -Type string `
    #                                       -Min 1 `
    #                                       -Max 10
    #     $schema | Should -Not -Be $null
    #     $prop = $schema.definitions.custom.properties | Get-Member -Name oktaPosh -MemberType NoteProperty
    #     $prop | Should -Not -Be $null
    #     $prop = $schema.definitions.custom.properties.oktaPosh
    #     $prop.title | Should -Be 'oktaPosh'
    #     $prop.type | Should -Be 'string'
    #     $prop.minLength | Should -Be 1
    #     $prop.maxLength | Should -Be 10
    # }

    # It "Removes a schema value" {
    #     $schema = Remove-OktaApplicationSchemaProperty -AppId $vars.app.id `
    #                                       -Name oktaPosh -Confirm:$false
    #     $schema | Should -Not -Be $null
    #     $prop = $schema.definitions.custom.properties | Get-Member -Name oktaPosh
    #     $prop | Should -Be $null
    # }

    # It "Adds and removes a Group" {
    #     $group = New-OktaGroup 'test-group-app'
    #     $group | Should -Not -Be $null
    #     $assigment = Add-OktaApplicationGroup -AppId $vars.app.id -GroupId $group.Id
    #     $assigment | Should -Not -Be $null
    #     $assigment.id | Should -Be $group.id

    #     $assigment = Get-OktaApplicationGroup -AppId $vars.app.id -GroupId $group.Id
    #     $assigment.id | Should -Be $group.id

    #     $assigments = @(Get-OktaApplicationGroup -AppId $vars.app.id)
    #     $assigments.count | Should -Be 1

    #     Remove-OktaApplicationGroup -AppId $vars.app.id -GroupId $group.Id -Confirm:$false
    #     $groups = Get-OktaApplicationGroup -AppId $vars.app.id
    #     $groups | Should -Be $null

    #     Remove-OktaGroup -GroupId $group.id -Confirm:$false
    # }

    # It "Gets Application User" {
    #     # onces the Add/Remove functions are added, flesh this out
    #     $users = Get-OktaApplicationUser -AppId $vars.app.id
    #     $users | Should -Be $null
    # }
}

# Describe "Cleanup" {
#     It 'Removes Application' {
#         if ($vars.app) {
#             Remove-OktaApplication -AppId $vars.app.Id -Confirm:$false
#         }

#         if ($vars.spaApp) {
#             Remove-OktaApplication -AppId $vars.spaApp.Id -Confirm:$false
#         }
#     }
# }


