BeforeAll {
    . (Join-Path $PSScriptRoot '../setup.ps1') -Unit
}

# Pester 5 need to pass in TestCases object to pass share
$PSDefaultParameterValues = @{
    "It:TestCases" = @{
        appName = "test-app"
        spaAppName = "test-spa-app"
        groupName      = 'test-group-app'
        email          = 'apptestuser@mailinator.com'
        vars = @{
            app        = @{id = '0oa3mo3swhHpQbzOw4u7';label="test-app"}
            spaApp     = $null
            schema     = $null
            user       = @{id = '00u3mo3swhHpQbzOw4u7';login='User123';email='user123@test.com'}
        }
    }
}

Describe "Cleanup" {
    It 'Removes Test Data' {
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
    It "Gets Application by as Query as Id" {
        $null = Get-OktaApplication -Query $vars.app.Id
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/apps/$($vars.app.Id)" -and $Method -eq 'GET'
                }
    }
    It "Gets Application by as Query" {
        $null = Get-OktaApplication -Query test
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/apps?q=test" -and $Method -eq 'GET'
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
        $group 	= @{id = "Group-12345567"}

        $null = New-OktaGroup $groupName
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

        Get-OktaGroupApp -GroupId $group.Id
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/groups/$($group.Id)/apps" -and $Method -eq 'GET'
                }

        Remove-OktaApplicationGroup -AppId $vars.app.id -GroupId $group.Id -Confirm:$false
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/apps/$($vars.app.Id)/groups/$($group.Id)" -and $Method -eq 'DELETE'
                }
        Remove-OktaGroup -GroupId $group.id -Confirm:$false
    }

    It "Adds and removes a user from the app" {
        $null = New-OktaUser -FirstName test-user -LastName test-user -Email $email
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/users?activate=false" -and $Method -eq 'POST'
                }

        $null = Add-OktaApplicationUser -AppId $vars.app.id -UserId $vars.user.id
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/apps/$($vars.app.id)/users/$($vars.user.id)" -and $Method -eq 'PUT'
                }

        $null = Get-OktaApplicationUser -AppId $vars.app.id
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/apps/$($vars.app.Id)/users" -and $Method -eq 'GET'
                }

        $null = Get-OktaApplicationUser -AppId $vars.app.id -UserId $vars.user.id
        $null = Get-OktaApplicationUser -AppId $vars.app.id -Query $vars.user.id
        Should -Invoke Invoke-WebRequest -Times 2 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/apps/$($vars.app.Id)/users/$($vars.user.id)" -and $Method -eq 'GET'
                }

        $null = Get-OktaApplicationUser -AppId $vars.app.id -Query test
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/apps/$($vars.app.Id)/users?q=test" -and $Method -eq 'GET'
                }

        $null = Get-OktaUserApplication -UserId $vars.user.id
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/apps?filter=user.id*&expand=user*" -and $Method -eq 'GET'
                }

        $null = Remove-OktaApplicationUser -AppId $vars.app.id -UserId $vars.user.id
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/apps/$($vars.app.Id)/users/$($vars.user.id)" -and $Method -eq 'DELETE'
                }
        $null = Get-OktaApplicationUser -AppId $vars.app.id
    }
}

Describe "Cleanup" {
    It 'Removes Application' {
        Mock Get-OktaApplication -ModuleName OktaPosh -MockWith { @{Label = $appName}}
        Mock Get-OktaUser -ModuleName OktaPosh -MockWith { @{status='PROVISIONED';profile=@{email="test";login="test"}}}
        if ($vars.user) {
            Remove-OktaUser -UserId $vars.user.id -Confirm:$false
        }

        (Get-OktaGroup -q $groupName) | Remove-OktaGroup -Confirm:$false

        if ($vars.app) {
            Remove-OktaApplication -AppId $vars.app.Id -Confirm:$false
            Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
            -ParameterFilter {
                $Uri -like "*/apps/$($vars.app.Id)" -and $Method -eq 'DELETE'
            }
        }

        if ($vars.spaApp) {
            Remove-OktaApplication -AppId $vars.spaApp.Id -Confirm:$false
        }
    }
}
