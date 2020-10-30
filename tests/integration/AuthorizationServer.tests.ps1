BeforeAll {
    . (Join-Path $PSScriptRoot setup.ps1)
}

# Pester 5 need to pass in TestCases object to pass share
$PSDefaultParameterValues = @{
    "It:TestCases" = @{
        authServerName = "Okta-Posh-Test"
        scopeNames     = "access:token", "get:item", "save:item", "remove:item"
        claimName      = "test-claim"
        policyName     = "test-policy"
        vars           = @{
            app        = $null
            authServer = $null
            scopes     = $null
            policy     = $null
            rule       = $null
        }
    }
}

Describe "AuthorizationServer" {

    It "Check for existing AuthServer" {
        $script:authServer = Get-OktaAuthorizationServer -Query $authServerName
        $script:authServer | Should -Be $null
    }

    It "Creates a new AuthServer" {
        $vars.authServer = New-OktaAuthorizationServer -Name $authServerName `
            -Audience "api://oktaposh/api" `
            -IssuerMode CUSTOM_URL_DOMAIN `
            -Description "OktaPosh Test Authorization Server"
        $vars.authServer | Should -Not -Be $null
    }

    It "Gets Authorization Servers" {
        $result = Get-OktaAuthorizationServer
        $result | Should -Not -Be $null
        $result.Count | Should -BeGreaterThan 0
    }

    It "Gets Authorization Server By Id" {
        $result = Get-OktaAuthorizationServer -AuthorizationServerId $vars.authServer.Id
        $result | Should -Not -Be $null
        $result.Id | Should -Be $vars.authServer.Id
    }

    It "Gets Authorization Server By Query" {
        $result = Get-OktaAuthorizationServer -Query 'test'
        $result | Should -Not -Be $null
        $result.Id | Should -Be $vars.authServer.Id
    }
    It "Updates an AuthorizationServer" {
        $result = Set-OktaAuthorizationServer -Id $vars.authServer.Id -Name $authServerName `
            -Description "new description" `
            -Audience $vars.authServer.audiences[0]
        $result | Should -Not -Be $null
        $result = Get-OktaAuthorizationServer -AuthorizationServerId $vars.authServer.Id
        $result.description | Should -Be "new description"
    }

    It "Disables Authorization Server" {
        Disable-OktaAuthorizationServer -Id $vars.authServer.Id -Confirm:$false
        $result = Get-OktaAuthorizationServer -AuthorizationServerId $vars.authServer.Id
        $result.status | Should -Be 'INACTIVE'
    }

    It "Enables Authorization Server" {
        Enable-OktaAuthorizationServer -Id $vars.authServer.Id
        $result = Get-OktaAuthorizationServer -AuthorizationServerId $vars.authServer.Id
        $result.status | Should -Be 'ACTIVE'
    }

    It "Creates new scopes" {
        $newScopes = $scopeNames | New-OktaScope -AuthorizationServerId $vars.authServer.id
        $newScopes.Count | Should -Be $scopeNames.Count
    }
    It "Gets scopes" {
        $vars.scopes = Get-OktaScope -AuthorizationServerId $vars.authServer.id
        $vars.scopes | Should -Not -Be $null
        $vars.scopes.Count | Should -Be $scopeNames.Count
    }

    It "Creates new Claim" {
        $claim = New-OktaClaim -AuthorizationServerId $vars.authServer.id `
            -Name $claimName -ValueType EXPRESSION -ClaimType RESOURCE `
            -Value "app.profile.$claimName" -Scopes "access:token"
        $claim | Should -Not -Be $null
    }
    It "Gets Claim" {
        $claim = Get-OktaClaim -AuthorizationServerId $vars.authServer.id -Query $claimName
        $claim | Should -Not -Be $null
        $claim.Name | Should -Be $claimName
    }

    It "Adds a policy" {
        $vars.app = New-OktaServerApplication -Label PolicyTestApp
        $vars.policy = New-OktaPolicy -AuthorizationServerId $vars.authServer.Id -Name $policyName -ClientIds $vars.app.Id
        $vars.policy | Should -Not -Be $null

        $vars.policy = Get-OktaPolicy -AuthorizationServerId  $vars.authServer.Id -Query $policyName
    }

    It "Get a policy by name" {
        $vars.policy = Get-OktaPolicy -AuthorizationServerId  $vars.authServer.Id -Query $policyName
        $vars.policy.Name | Should -Be $policyName
    }
    It "Get a policy by Id" {
        $vars.policy = Get-OktaPolicy -AuthorizationServerId $vars.authServer.Id -Id $vars.policy.Id
        $vars.policy.Name | Should -Be $policyName
    }


    It "Adds a rule" {
        $vars.rule = New-OktaRule -AuthorizationServerId $vars.authServer.Id `
            -PolicyId $vars.policy.id `
            -Name "Allow $($policyName)" `
            -Priority 1 `
            -GrantTypes client_credentials -Scopes $scopeNames

        $vars.rule | Should -Not -Be $null
    }
    It "Gets a rule by search" {
        $vars.rule = Get-OktaRule -AuthorizationServerId $vars.authServer.id -PolicyId $vars.policy.id -Query "Allow $($policyName)"
        $vars.rule | Should -Not -Be $null
        $vars.rule.Id | Should -Be $vars.rule.Id
    }
}

Describe "Cleanup" {
    It 'Removes AuthServer and App' {
        Remove-OktaApplication -AppId $vars.app.id  -Confirm:$false
        Remove-OktaAuthorizationServer -AuthorizationServerId $vars.authServer.id -Confirm:$false
    }
}


