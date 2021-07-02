BeforeAll {
    . (Join-Path $PSScriptRoot '../setup.ps1')
}

# Pester 5 need to pass in TestCases object to pass share
$PSDefaultParameterValues = @{
    "It:TestCases" = @{
        testAuthName    = "buildAuth-test"
        testAppName     = "buildApp-test"
        scopes         = @('scope:test1','scope:test2')
        vars            = @{
            auth        = $null
            app         = $null
        }
    }
}

Describe "Cleanup" {
    It 'Removes Test Data' {
        (Get-OktaAuthorizationServer -q $testAuthName) | Remove-OktaAuthorizationServer -Confirm:$false
    }
}

Describe "Build Okta Auth server tests" {
    It "Build existing auth server" {
        $vars.auth = Build-OktaAuthorizationServer `
            -Name $testAuthName `
            -Description 'test' `
            -Audience 'api.test.com' `
            -Scopes $scopes
        $vars.auth.name | Should -Be $testAuthName
        $scopes = Get-OktaScope -AuthorizationServerId $vars.auth.id
        $scopes.name | Should -Contain 'scope:test1'
        $scopes.name | Should -Contain 'scope:test2'
    }
    It "Tests New App" {
        $vars.app = Build-OktaSpaApplication `
            -Label $testAppName `
            -RedirectUris 'https://a.test.com','https://b.test.com' `
            -LoginUri 'https://l.test.com' `
            -PostLogoutUris 'https://c.test.com','https://d.test.com' `
            -SignOnMode "OPENID_CONNECT" `
            -GrantTypes 'implicit','authorization_code' `
            -Scopes 'scope:test1','scope:test2' `
            -AuthServerId $vars.auth.id
        $vars.app.label | Should -Be $testAppName
        (Get-OktaPolicy -AuthorizationServerId $vars.auth.id -q "$testAppName-Policy") | Should -Not -BeNull
    }
}

Describe "Cleanup" {
    It 'Removes Test Data' {
        if ($vars.auth){
            Remove-OktaAuthorizationServer -AuthorizationServerId $vars.auth.id -Confirm:$false
        }
        if ($vars.app){
            Remove-OktaApplication -AppId $vars.app.id -Confirm:$false
        }

    }
}
