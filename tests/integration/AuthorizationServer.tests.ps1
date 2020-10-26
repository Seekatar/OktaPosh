
# Pester 5 need to pass in TestCases object to pass share
$PSDefaultParameterValues = @{
    "It:TestCases" = @{ authServerName = "Okta-Posh-Test"
        scopeNames                     = "access:token", "get:item", "save:item", "remove:item"
        claimName                      = "test-claim"
        policyName                     = "test-policy"
        appName                        = "test-app"
        vars                           = @{
            authServer = $null
            app        = $null
            scopes     = $null
            policy     = $null
            rule       = $null
        }
    }
}

# OR ???

BeforeAll {
    . (Join-Path $PSScriptRoot setup.ps1)
    $authServerName = "Okta-Posh-Test"
    $scopes = "access:token","get:item","save:item","remove:item"
    $claimName = "appName"

    $script:authServer = $null
}

Describe "AuthorizationServer" {

    It "Check for existing AuthServer" {
        $script:authServer = Get-OktaAuthorizationServer -Query $authServerName
        $script:authServer | Should -Be $null
    }

    It "Creates a new AuthServer" {
        $vars.authServer = New-OktaAuthorizationServer -Name $authServerName `
            -Audience "api://oktaposh/api" `
            -Issuer "$(Get-OktaBaseUri)/oauth2/default" `
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


    It "Adds a policy" {
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
    It 'Removes Application' {
        Get-OktaApplication |
        Where-Object Label -eq $appName |
        Remove-OktaApplication -Confirm:$false
    }

    It 'Removes AuthServer' {
        Get-OktaAuthorizationServer |
        Where-Object Name -eq $authServerName |
        Select-Object -expand Id |
        Remove-OktaAuthorizationServer -Confirm:$false
    }
}


