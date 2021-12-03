BeforeAll {
    . (Join-Path $PSScriptRoot '../setup.ps1')
}

# Pester 5 need to pass in TestCases object to pass share
$PSDefaultParameterValues = @{
    "It:TestCases" = @{
        testAppName     = "Test-API-App" # must exist
        username        = "wflintstone@mailinator.com"
        appName         = "OktaPosh-test-policy-app"
        spaAppName      = "OktaPosh-test-spa-app"
        userPw          = "Test123!"
        authServerName  = "OktaPosh-Test"
        scopeNames      = "access:token", "get:item", "save:item", "remove:item"
        claimName       = "OktaPosh-test-claim"
        policyName      = "OktaPosh-test-policy"
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

Describe "Cleanup" {
    It 'Removes AuthServer and App' {
        (Get-OktaUser -q $username) | Remove-OktaUser -Confirm:$false
        (Get-OktaApplication -q $appName) | Remove-OktaApplication -Confirm:$false
        (Get-OktaApplication -q $spaAppName) | Remove-OktaApplication -Confirm:$false
        (Get-OktaAuthorizationServer -q $authServerName) | Remove-OktaAuthorizationServer -Confirm:$false
    }
}

Describe "Setup" {
    It 'Set API App from env' {
        Set-OktaOption | Should -BeTrue
    }
    It 'Set API App from env' {
        # avoid warning message with 3>
        (Set-OktaOption -ApiToken '' 3> $null) | Should -BeFalse
    }
    It 'Get API token ' {
        Get-OktaApiToken -ApiToken 'abc' | Should -Be 'abc'
    }
    It 'Get Base Uri ' {
        Get-OktaBaseUri -OktaBaseUri 'abc' | Should -Be 'abc'
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

        $result = Get-OktaAuthorizationServer -Query $vars.authServer.Id
        $result.Id | Should -Be $vars.authServer.Id
    }
    It "Gets Authorization Server By Query" {
        $result = Get-OktaAuthorizationServer -Query 'OktaPosh'
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
    It "Get OktaOpenIdConfig" {
        $result = Get-OktaOpenIdConfig -AuthorizationServerId $vars.authServer.Id
        $result | Should -Not -Be $null
        $result.issuer | Should -Be $vars.authServer.issuer
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
     It "Gets scopes by Id" {
        $scope = Get-OktaScope -AuthorizationServerId $vars.authServer.id -Query $vars.scopes[0].Id
        $scope.id | Should -Be $vars.scopes[0].Id
        $scope = Get-OktaScope -AuthorizationServerId $vars.authServer.id -ScopeId $vars.scopes[0].Id
        $scope.id | Should -Be $vars.scopes[0].Id
    }
    It "Updates a scope" {
        $vars.scopes[0].description = 'Updated description'
        $update = Set-OktaScope -AuthorizationServerId $vars.authServer.id -Scope $vars.scopes[0]
        $update.description | Should -Be $vars.scopes[0].description
    }
    It "Creates new Expression Claim" {
        $vars.claim = New-OktaClaim -AuthorizationServerId $vars.authServer.id `
            -Name $claimName -ValueType EXPRESSION -ClaimType RESOURCE `
            -Value "app.profile.$claimName" -Scopes $scopeNames[0]
        $vars.claim | Should -Not -Be $null
    }
    It "Creates new Group Claim" {
        $claim = New-OktaClaim -AuthorizationServerId $vars.authServer.id `
            -Name $claimName -ValueType GROUPS -ClaimType ID_TOKEN `
            -GroupFilterType STARTS_WITH -Value "casualty-group" -Scopes "access:token" `

        $claim | Should -Not -Be $null
    }
    It "Gets Claim By Name" {
        $claim = Get-OktaClaim -AuthorizationServerId $vars.authServer.id -Query $claimName
        $claim | Should -Not -Be $null
        $claim.Count | Should -Be 2
        $claim[0].Name | Should -Be $claimName
        $claim[1].Name | Should -Be $claimName
    }
    It "Gets Claim By Id" {
        $claim = Get-OktaClaim -AuthorizationServerId $vars.authServer.Id -ClaimId $vars.claim.id
        $claim | Should -Not -Be $null
        $claim.Name | Should -Be $claimName
        $claim = Get-OktaClaim -AuthorizationServerId $vars.authServer.Id -Query $vars.claim.id
        $claim | Should -Not -Be $null
        $claim.id | Should -Be $vars.claim.id
    }
    It "Updates a Claim" {
        $vars.claim.name = "Updated"
        $update = Set-OktaClaim -AuthorizationServerId $vars.authServer.Id -Claim $vars.claim
        $update.name | Should -Be $vars.claim.name
    }
    It "Adds a server application" {
        $vars.app = New-OktaServerApplication -Label $appName -Properties @{appName = $appName }
        $vars.app | Should -Not -Be $null
        $vars.app = Set-OktaApplication $vars.app # to get the secret
        $vars.app.credentials.oauthClient.client_secret | Should -Not -Be $null
    }
    It "Adds a SPA application" {
        $vars.spaApp = New-OktaSpaApplication -Label $spaAppName -RedirectUris "http://gohome" -LoginUri "http://login"
        $vars.spaApp | Should -Not -Be $null
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
        $vars.policy = Get-OktaPolicy -AuthorizationServerId $vars.authServer.Id -Query $vars.policy.Id
        $vars.policy.id | Should -Be $vars.policy.Id
    }
    It "Updates a policy" {
        $vars.policy.description = "Updated policy"
        $update = Set-OktaPolicy -AuthorizationServerId $vars.authServer.id -Policy $vars.policy
        $update.description | Should -Be $vars.policy.description
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
    It "Gets a rule by Id" {
        $rule = Get-OktaRule -AuthorizationServerId $vars.authServer.id -PolicyId $vars.policy.id -Id $vars.rule.id
	$rule.id | Should -Be $vars.rule.id
        $rule = Get-OktaRule -AuthorizationServerId $vars.authServer.id -PolicyId $vars.policy.id -Query $vars.rule.id
	$rule.id | Should -Be $vars.rule.id
    }
    It "Updates a rule" {
        $vars.rule.name = "Updated description"
        $update = Set-OktaRule -AuthorizationServerId $vars.authServer.id -PolicyId $vars.policy.id -Rule $vars.rule
        $update.name | Should -Be $vars.rule.name
    }
    It "Adds SPA Access" {
        $policy = New-OktaPolicy -AuthorizationServerId $vars.authServer.Id -Name "SPA-$policyName" -ClientIds $vars.spaApp.Id
        $policy | Should -Not -Be $null

        $rule = New-OktaRule -AuthorizationServerId $vars.authServer.Id `
            -PolicyId $policy.id `
            -Name "Allow $($policyName)" `
            -Priority 1 `
            -GrantTypes implicit -Scopes $scopeNames
        $rule | Should -Not -Be $null
    }
    It "Exports an auth server" {
        $result = Export-OktaAuthorizationServer -AuthorizationServerId $vars.authServer.id -OutputFolder ([System.IO.Path]::GetTempPath())
        $result.Count | Should -BeGreaterThan 4
        $result | ForEach-Object { Get-Content $_ -Raw | ConvertFrom-Json }
        $result | Remove-Item
    }
    It "Tests Server JWT Access" {
        $jwt = Get-OktaAppJwt -ClientId $vars.app.Id -ClientSecret $vars.app.credentials.oauthClient.client_secret -Scopes $scopeNames[0] -Issuer $vars.authServer.issuer
        [bool]$jwt | Should -BeTrue
    }
    It "Tests Server JWT Access With SecureString" {
        $jwt = Get-OktaAppJwt -ClientId $vars.app.Id -SecureClientSecret (ConvertTo-SecureString $vars.app.credentials.oauthClient.client_secret -AsPlainText -Force) -Scopes $scopeNames[0] -Issuer $vars.authServer.issuer
        [bool]$jwt | Should -BeTrue
    }
    It "Tests Server JWT Access Invalid Parameter" {
        { Get-OktaAppJwt -Scopes $scopeNames[0] 3>$null } | Should -Throw 'Missing required*'
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
            [bool]$jwt | Should -BeTrue
        }
    }
    It "Tests User JWT Access with SecureString" {
        # not working on 5 for some reason
        if ($PSVersionTable.PSVersion.Major -ge 7) {
            # Write-Warning "Get-OktaJwt -ClientId $($vars.spaApp.id) -Issuer $($vars.authServer.issuer) -ClientSecret $userPw -Username $userName -Scopes $($scopeNames[0]) -RedirectUri $redirectUri"
            $jwt = Get-OktaJwt -ClientId $vars.spaApp.id `
                        -Issuer $vars.authServer.issuer `
                        -SecureClientSecret (ConvertTo-SecureString $userPw -AsPlainText -Force) `
                        -Username $userName `
                        -Scopes $scopeNames[0] `
                        -RedirectUri $redirectUri
            [bool]$jwt | Should -BeTrue
        }
    }
    It "Removes a Policy Rule" {
        Remove-OktaRule -AuthorizationServerId $vars.authServer.id -PolicyId $vars.policy.id -RuleId $vars.rule.id -Confirm:$false
    }
    It "Removes a Policy" {
        Remove-OktaPolicy -AuthorizationServerId $vars.authServer.Id -PolicyId $vars.policy.id -Confirm:$false
    }
    It "Removes a scope" {
        Remove-OktaScope -AuthorizationServerId $vars.authServer.id -ScopeId $vars.scopes[0].id -Confirm:$false
    }
    It "Removes a Claim" {
        Remove-OktaClaim -AuthorizationServerId $vars.authServer.Id -ClaimId $vars.claim.id -Confirm:$false
    }
}

Describe "Cleanup" {
    It "Removes a Claim By Id" {
        Remove-OktaClaim -AuthorizationServerId $vars.authServer.Id -ClaimId $vars.claim.id -Confirm:$false 3>$null
        $claim = Get-OktaClaim -AuthorizationServerId $vars.authServer.Id -ClaimId $vars.claim.id
        $claim | Should -Be $null
    }
    It 'Removes AuthServer and App' {
        Remove-OktaApplication -Id $vars.app.id -Confirm:$false
        Remove-OktaApplication -Id $vars.spaApp.id -Confirm:$false
        Remove-OktaUser -Id $vars.user.id -Confirm:$false
        Remove-OktaAuthorizationServer -AuthorizationServerId $vars.authServer.id -Confirm:$false
    }
}
