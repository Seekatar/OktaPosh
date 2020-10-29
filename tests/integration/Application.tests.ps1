BeforeAll {
    . (Join-Path $PSScriptRoot setup.ps1)
}

# Pester 5 need to pass in TestCases object to pass share
$PSDefaultParameterValues = @{
    "It:TestCases" = @{
        appName        = "test-app"
        vars           = @{
            app        = $null
            schema     = $null
        }
    }
}

Describe "Application" {
    It "Adds an application" {
        $vars.app = New-OktaServerApplication -Label $appName -Properties @{appName = $appName }
        $vars.app | Should -Not -Be $null
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
}

Describe "Cleanup" {
    It 'Removes Application' {
        Get-OktaApplication |
        Where-Object Label -eq $appName |
        Remove-OktaApplication -Confirm:$false
    }
}


