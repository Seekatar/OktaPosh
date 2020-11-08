BeforeAll {
    . (Join-Path $PSScriptRoot '../setup.ps1')
}

# Pester 5 need to pass in TestCases object to pass share
$PSDefaultParameterValues = @{
    "It:TestCases" = @{
        testAppName     = "Test-API-App" # must exist
        username        = "wflintstone@mailinator.com"
        appName         = "test-policy-app"
        spaAppName      = "test-spa-app"
        userPw          = "Test123!"
        authServerName  = "Okta-Posh-Test"
        scopeNames      = "access:token", "get:item", "save:item", "remove:item"
        claimName       = "test-claim"
        policyName      = "test-policy"
        redirectUri     = "http://gohome"
        vars            = @{
            app         = $null
            spaApp      = $null
            authServer  = $null
            scopes      = $null
            policy      = $null
            rule        = $null
            user        = $null
            claim       = $null
        }
    }
}

Describe "Setup" {
    It 'Get API App' {

        Set-OktaOption

        # can't get secret to test getting JWT via API, so it must exist
        $vars.app = Get-OktaApplication -q $testAppName
        $vars.app | Should -Not -Be $null
    }
    It 'Removes AuthServer and App' {
        (Get-OktaUser -q $username) | Remove-OktaUser -Confirm:$false
        (Get-OktaApplication -q $appName) | Remove-OktaApplication -Confirm:$false
        (Get-OktaApplication -q $spaAppName) | Remove-OktaApplication -Confirm:$false
        (Get-OktaAuthorizationServer -q $authServerName) | Remove-OktaAuthorizationServer -Confirm:$false
    }
}

Describe "AuthorizationServer" {

    It "Check for existing AuthServer" {
        $vars.authServer = Get-OktaAuthorizationServer -Query $authServerName
        $vars.authServer | Should -Be $null
    }
    It "Creates a new AuthServer" {
        $vars.authServer = New-OktaAuthorizationServer -Name $authServerName `
            -Audience "api://oktaposh/api" `
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
        $vars.claim = New-OktaClaim -AuthorizationServerId $vars.authServer.id `
            -Name $claimName -ValueType EXPRESSION -ClaimType RESOURCE `
            -Value "app.profile.$claimName" -Scopes $scopeNames[0]
        $vars.claim | Should -Not -Be $null
    }
    It "Gets Claim" {
        $claim = Get-OktaClaim -AuthorizationServerId $vars.authServer.id -Query $claimName
        $claim | Should -Not -Be $null
        $claim.Name | Should -Be $claimName
    }
    It "Gets Claim By Id" {
        $claim = Get-OktaClaim -AuthorizationServerId $vars.authServer.Id -ClaimId $vars.claim.id
        $claim | Should -Not -Be $null
        $claim.Name | Should -Be $claimName
    }
    It "Adds a policy" {
        $vars.policy = New-OktaPolicy -AuthorizationServerId $vars.authServer.Id -Name $policyName -ClientIds $vars.app.Id
        $vars.policy | Should -Not -Be $null

        $vars.policy = Get-OktaPolicy -AuthorizationServerId  $vars.authServer.Id -Query $policyName
        $vars.policy | Should -Not -Be $null
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
    It "Tests Server JWT Access" {
        $jwt = Get-OktaAppJwt -ClientId $vars.app.Id -ClientSecret $env:OKTA_CLIENT_SECRET -Scopes $scopeNames[0] -Issuer $vars.authServer.issuer
        [bool]$jwt | Should -Be $true
    }
    It "Adds SPA Access" {
        $vars.spaApp = New-OktaSpaApplication -Label $spaAppName -RedirectUris $redirectUri -LoginUri "http://login"
        $vars.spaApp | Should -Not -Be $null

        $policy = New-OktaPolicy -AuthorizationServerId $vars.authServer.Id -Name "SPA-$policyName" -ClientIds $vars.spaApp.Id
        $policy | Should -Not -Be $null

        $vars.rule = New-OktaRule -AuthorizationServerId $vars.authServer.Id `
            -PolicyId $policy.id `
            -Name "Allow $($policyName)" `
            -Priority 1 `
            -GrantTypes implicit -Scopes $scopeNames
            $vars.rule | Should -Not -Be $null
    }
    It "Tests User JWT Access" {
        $vars.user = New-OktaUser -FirstName Wilma -LastName Flintsone -Email $username -Activate -Pw $userPw
        $vars.user | Should -Not -Be $null
        $result = Add-OktaApplicationUser -AppId $vars.spaApp.id -UserId $vars.user.Id
        $result | Should -Not -Be $null

        # not working on 5 for some reason
        if ($PSVersionTable.PSVersion.Major -ge 7) {
            # Write-Warning "Get-OktaJwt -ClientId $($vars.spaApp.id) -Issuer $($vars.authServer.issuer) -ClientSecret $userPw -Username $userName -Scopes $($scopeNames[0]) -RedirectUri $redirectUri"
            $jwt = Get-OktaJwt -ClientId $vars.spaApp.id `
                        -Issuer $vars.authServer.issuer `
                        -ClientSecret $userPw `
                        -Username $userName -Scopes $scopeNames[0] `
                        -RedirectUri $redirectUri
            [bool]$jwt | Should -Be $true
        }
    }
    It "Exports an auth server" {
        $result = Export-OktaAuthorizationServer -AuthorizationServerId $vars.authServer.id -OutputFolder ([System.IO.Path]::GetTempPath())
        $result.Count | Should -BeGreaterThan 4
        $result | Remove-Item
    }
}

# Describe "Cleanup" {
#     It "Removes a Claim By Id" {
#         Remove-OktaClaim -AuthorizationServerId $vars.authServer.Id -ClaimId $vars.claim.id -Confirm:$false
#         $claim = Get-OktaClaim -AuthorizationServerId $vars.authServer.Id -ClaimId $vars.claim.id
#         $claim | Should -Be $null
#     }
#     It 'Removes AuthServer and App' {
#         Remove-OktaApplication -Id $vars.spaApp.id -Confirm:$false
#         Remove-OktaUser -Id $vars.user.id -Confirm:$false
#         Remove-OktaAuthorizationServer -AuthorizationServerId $vars.authServer.id -Confirm:$false
#     }
# }


