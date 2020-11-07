BeforeAll {
    . (Join-Path $PSScriptRoot '../setup.ps1') -Unit
}

# Pester 5 need to pass in TestCases object to pass share
$PSDefaultParameterValues = @{
    "It:TestCases" = @{
        group = @{Id = "12345567"}
        appName = "test-app"
        spaAppName = "test-spa-app"
        vars = @{
            app = @{id = 1234;label="test-app"}
        }
    }
}

Describe "Application Tests" {
    It "Adds a server application" {
        $null = New-OktaServerApplication -Label $appName -Properties @{appName = $appName }
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/apps" -and $Method -eq 'POST'
                }
    }
    It "Adds a SPA application" {
        $null = New-OktaSpaApplication -Label $spaAppName -RedirectUris "http://gohome" -LoginUri "http://login"
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/apps" -and $Method -eq 'POST'
                }
    }
    It "Gets Applications" {
        $null = Get-OktaApplication
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/apps" -and $Method -eq 'GET'
                }
    }
    It "Gets Application by Id" {
        $null = Get-OktaApplication -ApplicationId $vars.app.Id
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/apps/$($vars.app.Id)" -and $Method -eq 'GET'
                }
    }
    It "Disables Application" {
        Disable-OktaApplication -Id $vars.app.Id -Confirm:$false
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*apps/$($vars.app.Id)/lifecycle/deactivate" -and $Method -eq 'POST'
                }
    }
    It "Enables Application" {
        Enable-OktaApplication -Id $vars.app.Id
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*apps/$($vars.app.Id)/lifecycle/activate" -and $Method -eq 'POST'
                }
    }
    It "Set an Application" {
        $vars.app.label = "test-updated"
        $null = Set-OktaApplication -Application $vars.app
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*apps/$($vars.app.Id)" -and $Method -eq 'PUT'
                }
    }
    It "Sets profile property" {
        Set-OktaApplicationProperty -App $vars.app -Properties @{testProp = 'hi there' }
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*apps/$($vars.app.Id)" -and $Method -eq 'PUT'
                }
    }
    It "Adds Schema" {
        $null = Get-OktaApplicationSchema -AppId $vars.app.id
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/meta/schemas/apps/$($vars.app.Id)/default" -and $Method -eq 'GET'
                }
    }
    It "Sets a schema value" {
        $null = Set-OktaApplicationSchemaProperty -AppId $vars.app.id `
                                          -Name oktaPosh `
                                          -Type string `
                                          -Min 1 `
                                          -Max 10
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/meta/schemas/apps/$($vars.app.Id)/default" -and $Method -eq 'POST'
                }
    }
    It "Removes a schema value" {
        $null = Remove-OktaApplicationSchemaProperty -AppId $vars.app.id `
                                          -Name oktaPosh -Confirm:$false
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/meta/schemas/apps/$($vars.app.Id)/default" -and $Method -eq 'POST'
                }
    }
    It "Adds and removes a Group" {
        $null = Add-OktaApplicationGroup -AppId $vars.app.id -GroupId $group.Id
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/apps/$($vars.app.Id)/groups/$($group.Id)" -and $Method -eq 'PUT'
                }

        $null = Get-OktaApplicationGroup -AppId $vars.app.id -GroupId $group.Id
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/apps/$($vars.app.Id)/groups/$($group.Id)" -and $Method -eq 'GET'
                }

        $null = @(Get-OktaApplicationGroup -AppId $vars.app.id)
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/apps/$($vars.app.Id)/groups" -and $Method -eq 'GET'
                }

        Remove-OktaApplicationGroup -AppId $vars.app.id -GroupId $group.Id -Confirm:$false
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/apps/$($vars.app.Id)/groups/$($group.Id)" -and $Method -eq 'DELETE'
                }
    }

    It "Adds and removes a user from the app" {
        $userId = "132-234-234"
        $null = Add-OktaApplicationUser -AppId $vars.app.id -UserId $userId
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/apps*&expand=user%2F$UserId*" -and $Method -eq 'PUT'
                }

        $null = Get-OktaApplicationUser -AppId $vars.app.id
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/apps/$($vars.app.Id)/users" -and $Method -eq 'GET'
                }

        $null = Get-OktaUserApplication -UserId $userId
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/apps/$($vars.app.Id)/users/$userId" -and $Method -eq 'DELETE'
                }

        $null = Remove-OktaApplicationUser -AppId $vars.app.id -UserId $userId
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/apps/$($vars.app.Id)/users/$userId" -and $Method -eq 'DELETE'
                }
    }
}

Describe "Cleanup" {
    It 'Removes Application' {
        Mock Get-OktaApplication -ModuleName OktaPosh -MockWith { @{Label = $appName}}
        if ($vars.app) {
            Remove-OktaApplication -AppId $vars.app.Id -Confirm:$false
            Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
            -ParameterFilter {
                $Uri -like "*/apps/$($vars.app.Id)" -and $Method -eq 'DELETE'
            }
        }
    }
}
