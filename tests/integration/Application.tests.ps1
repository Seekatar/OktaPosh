BeforeAll {
    . (Join-Path $PSScriptRoot '../setup.ps1')
}

# Pester 5 need to pass in TestCases object to pass share
$PSDefaultParameterValues = @{
    "It:TestCases" = @{
        appName        = "test-app"
        spaAppName     = "test-spa-app"
        groupName      = 'test-group-app'
        email          = 'apptestuser@mailinator.com'
        groupName2     = 'test-group-app2'
        email2         = 'apptestuser2@mailinator.com'
        vars           = @{
            app        = $null
            spaApp     = $null
            schema     = $null
            user       = $null
        }
    }
}

Describe "Cleanup" {
    It 'Removes Test Data' {
        (Get-OktaApplication -q $appName) | Remove-OktaApplication -Confirm:$false
        (Get-OktaApplication -q $spaAppName) | Remove-OktaApplication -Confirm:$false
        (Get-OktaUser -q $email) | Remove-OktaUser -Confirm:$false
        (Get-OktaGroup -q $groupName) | Remove-OktaGroup -Confirm:$false
        (Get-OktaUser -q $email2) | Remove-OktaUser -Confirm:$false
        (Get-OktaGroup -q $groupName2) | Remove-OktaGroup -Confirm:$false
    }
}


Describe "Application Tests" {
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

        $total = $result.count
        $limit = [int]($total/2)+1
        $result = Get-OktaApplication -Limit $limit
        $result.Count | Should -Be $limit
        Test-OktaNext apps | Should -BeTrue
        $result = Get-OktaApplication -Next
        $result.Count | Should -Be ($total - $limit)
        Test-OktaNext apps | Should -BeFalse
    }
    It "Gets Application by Id" {
        $result = Get-OktaApplication -ApplicationId $vars.app.Id
        $result.Id | Should -Be $vars.app.Id
        $result = Get-OktaApplication -Query $vars.app.Id
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
        $group = New-OktaGroup $groupName
        $group | Should -Not -Be $null
        $group = Add-OktaApplicationGroup -AppId $vars.app.id -GroupId $group.Id
        $group | Should -Not -Be $null
        $group.id | Should -Be $group.id
        $group2 = New-OktaGroup $groupName2
        $group2 | Should -Not -Be $null
        $null = Add-OktaApplicationGroup -AppId $vars.app.id -GroupId $group2.Id
        $null = Add-OktaApplicationGroup -AppId $vars.spaApp.id -GroupId $group2.Id

        $group = Get-OktaApplicationGroup -AppId $vars.app.id -GroupId $group.Id
        $group.id | Should -Be $group.id

        $groups = @(Get-OktaApplicationGroup -AppId $vars.app.id)
        $groups.count | Should -Be 2

        $groups = @(Get-OktaApplicationGroup -AppId $vars.app.id -limit 1)
        $groups.Count | Should -Be 1
        Test-OktaNext "apps/$($vars.app.id)/groups" | Should -BeTrue
        $groups = @(Get-OktaApplicationGroup -AppId $vars.app.id -next)
        $groups.Count | Should -Be 1
        Test-OktaNext "apps/$($vars.app.id)/groups" | Should -BeFalse

        $apps = @(Get-OktaGroupApp -GroupId $group.Id)
        $apps.Count | Should -BeGreaterThan 0

        $apps = @(Get-OktaGroupApp -GroupId $group2.Id -Limit 1)
        $apps.Count | Should -Be 1
        Test-OktaNext "groups/$($group2.id)/apps" | Should -BeTrue
        $apps = @(Get-OktaGroupApp -GroupId $group2.Id -next)
        $apps.Count | Should -Be 1
        Test-OktaNext "groups/$($group2.id)/apps" | Should -BeFalse

        Remove-OktaApplicationGroup -AppId $vars.app.id -GroupId $group.Id -Confirm:$false
        Remove-OktaApplicationGroup -AppId $vars.app.id -GroupId $group2.Id -Confirm:$false
        $groups = Get-OktaApplicationGroup -AppId $vars.app.id
        $groups | Should -Be $null

        Remove-OktaGroup -GroupId $group.id -Confirm:$false
    }

    It "Adds and removes a user from the app" {
        $vars.user = New-OktaUser -FirstName test-user -LastName test-user -Email $email
        $vars.user | Should -Not -Be $null
        $user2 = New-OktaUser -FirstName test-user2 -LastName test-user2 -Email $email2
        $user2 | Should -Not -Be $null

        $null = Add-OktaApplicationUser -AppId $vars.app.id -UserId $vars.user.id
        $null = Add-OktaApplicationUser -AppId $vars.app.id -UserId $user2.id
        $users = @(Get-OktaApplicationUser -AppId $vars.app.id)
        $users.Count | Should -Be 2

        $user = Get-OktaApplicationUser -AppId $vars.app.id -UserId $vars.user.id
	$user.id | Should -Be $vars.user.id
        $user = Get-OktaApplicationUser -AppId $vars.app.id -Query $vars.user.id
	$user.id | Should -Be $vars.user.id

        $users = @(Get-OktaApplicationUser -AppId $vars.app.id -limit 1)
        $users.Count | Should -Be 1
        Test-OktaNext "apps/$($vars.app.id)/users" | Should -BeTrue
        $users = @(Get-OktaApplicationUser -AppId $vars.app.id -next)
        $users.Count | Should -Be 1
        Test-OktaNext "apps/$($vars.app.id)/users" | Should -BeFalse

        $result = Get-OktaUserApplication -UserId $vars.user.id
        $result | Should -Not -Be $null
        Remove-OktaApplicationUser -AppId $vars.app.id -UserId $vars.user.id
        Remove-OktaApplicationUser -AppId $vars.app.id -UserId $user2.id
        $users = Get-OktaApplicationUser -AppId $vars.app.id
        ($users -eq $null -or $users.Count -eq 0) | Should -BeTrue
    }
}

Describe "Cleanup" {
    It 'Removes Application' {
        if ($vars.user) {
            Remove-OktaUser -UserId $vars.user.id -Confirm:$false
        }

        (Get-OktaGroup -q $groupName) | Remove-OktaGroup -Confirm:$false
        (Get-OktaUser -q $email2) | Remove-OktaUser -Confirm:$false
        (Get-OktaGroup -q $groupName2) | Remove-OktaGroup -Confirm:$false

        if ($vars.app) {
            Remove-OktaApplication -AppId $vars.app.Id -Confirm:$false
        }

        if ($vars.spaApp) {
            Remove-OktaApplication -AppId $vars.spaApp.Id -Confirm:$false
        }
    }
}


