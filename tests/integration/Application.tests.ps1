BeforeAll {
    . (Join-Path $PSScriptRoot setup.ps1)
}

# Pester 5 need to pass in TestCases object to pass share
$PSDefaultParameterValues = @{
    "It:TestCases" = @{
        appName        = "test-app"
        spaAppName     = "test-spa-app"
        email          = 'apptestuser@mailinator.com'
        vars           = @{
            app        = $null
            spaApp     = $null
            schema     = $null
            user       = $null
        }
    }
}

Describe "Application" {
    It "Adds a server application" {
        $vars.app = New-OktaServerApplication -Label $appName -Properties @{appName = $appName }
        $vars.app | Should -Not -Be $null
    }
    It "Adds a SPA application" {
        $vars.spaApp = New-OktaSpaApplication -Label $spaAppName -RedirectUris "http://gohome" -LoginUri "http://login"
        $vars.spaApp | Should -Not -Be $null
    }
    It "Gets Applications" {
        $result = Get-OktaApplication
        $result | Should -Not -Be $null
        $result.Count | Should -BeGreaterThan 0
    }
    It "Gets Application by Id" {
        $result = Get-OktaApplication -ApplicationId $vars.app.Id
        $result.Id | Should -Be $vars.app.Id
    }
    It "Disables Application" {
        Disable-OktaApplication -Id $vars.app.Id -Confirm:$false
        $result = Get-OktaApplication -ApplicationId $vars.app.Id
        $result.status | Should -Be 'INACTIVE'
    }
    It "Enables Application" {
        Enable-OktaApplication -Id $vars.app.Id
        $result = Get-OktaApplication -ApplicationId $vars.app.Id
        $result.status | Should -Be 'ACTIVE'
    }
    It "Set an Application" {
        $vars.spaApp.label = "test-updated"
        $result = Set-OktaApplication -Application $vars.spaApp
        $result.label | Should -Be $vars.spaApp.label
    }
    It "Sets profile property" {
        Set-OktaApplicationProperty -App $vars.app -Properties @{testProp = 'hi there' }
        $result = Get-OktaApplication -ApplicationId $vars.app.Id
        $result.profile.testProp | Should -Be 'hi there'
    }

    It "Adds Schema" {
        $vars.schema = Get-OktaApplicationSchema -AppId $vars.app.id
        $vars.schema | Should -Not -Be $null
    }

    It "Sets a schema value" {
        $schema = Set-OktaApplicationSchemaProperty -AppId $vars.app.id `
                                          -Name oktaPosh `
                                          -Type string `
                                          -Min 1 `
                                          -Max 10
        $schema | Should -Not -Be $null
        $prop = $schema.definitions.custom.properties | Get-Member -Name oktaPosh -MemberType NoteProperty
        $prop | Should -Not -Be $null
        $prop = $schema.definitions.custom.properties.oktaPosh
        $prop.title | Should -Be 'oktaPosh'
        $prop.type | Should -Be 'string'
        $prop.minLength | Should -Be 1
        $prop.maxLength | Should -Be 10
    }

    It "Removes a schema value" {
        $schema = Remove-OktaApplicationSchemaProperty -AppId $vars.app.id `
                                          -Name oktaPosh -Confirm:$false
        $schema | Should -Not -Be $null
        $prop = $schema.definitions.custom.properties | Get-Member -Name oktaPosh
        $prop | Should -Be $null
    }

    It "Adds and removes a Group" {
        $group = New-OktaGroup 'test-group-app'
        $group | Should -Not -Be $null
        $assigment = Add-OktaApplicationGroup -AppId $vars.app.id -GroupId $group.Id
        $assigment | Should -Not -Be $null
        $assigment.id | Should -Be $group.id

        $assigment = Get-OktaApplicationGroup -AppId $vars.app.id -GroupId $group.Id
        $assigment.id | Should -Be $group.id

        $assigments = @(Get-OktaApplicationGroup -AppId $vars.app.id)
        $assigments.count | Should -Be 1

        Remove-OktaApplicationGroup -AppId $vars.app.id -GroupId $group.Id -Confirm:$false
        $groups = Get-OktaApplicationGroup -AppId $vars.app.id
        $groups | Should -Be $null

        Remove-OktaGroup -GroupId $group.id -Confirm:$false
    }

    It "Adds and removes a user from the group" {
        $vars.user = New-OktaUser -FirstName test-user -LastName test-user -Email $email
        $vars.user | Should -Not -Be $null

        $null = Add-OktaApplicationUser -AppId $vars.app.id -UserId $vars.user.id
        $users = @(Get-OktaApplicationUser -AppId $vars.app.id)
        $users.Count | Should -Be 1
        Remove-OktaApplicationUser -AppId $vars.app.id -UserId $vars.user.id
        $users = @(Get-OktaApplicationUser -AppId $vars.app.id)
        $users.Count | Should -Be 0
    }
}

Describe "Cleanup" {
    It 'Removes Application' {
        if ($vars.user) {
            Remove-OktaUser -UserId $vars.user.id -Confirm:$false
        }

        if ($vars.app) {
            Remove-OktaApplication -AppId $vars.app.Id -Confirm:$false
        }

        if ($vars.spaApp) {
            Remove-OktaApplication -AppId $vars.spaApp.Id -Confirm:$false
        }
    }
}


