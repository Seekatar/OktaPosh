BeforeAll {
    . (Join-Path $PSScriptRoot '../setup.ps1') -Unit
}

# Pester 5 need to pass in TestCases object to pass share
$PSDefaultParameterValues = @{
    "It:TestCases" = @{
        testAppName     = "Test-API-App" # must exist
        username        = "wflintstone@mailinator.com"
        appName         = "OktaPosh-test-policy-app"
        spaAppName      = "OktaPosh-test-spa-app"
        userPw          = "Test123!"
        authServerName = "OktaPosh-test"
        scopeNames     = "access:token", "get:item", "save:item", "remove:item"
        claimName      = "OktaPosh-test-claim"
        policyName     = "OktaPosh-test-policy"
        redirectUri     = "http://gohome"
        policy         = @{ id = "policy-123-4675-67"}
        vars           = @{
            app        = @{ id = "00u3mo3swhHpQbzOw4u7"}
            spaApp     = @{ id = "00a3mo3swhHpQbzOw4u7"}
            claim      = @{ id = "ocl3mo3swhHpQbzOw4u7"; name="test"}
            authServer = @{ id = "aus3mo3swhHpQbzOw4u7";audiences=@("test");issuer="http://issuer"}
            scope      = @{ id = "scpu3mo3swhHpQbzOwu7"; name="test"}
            policy     = @{ id = "00p3mo3swhHpQbzOw4u7"; name="test"}
            rule       = @{ id = "0pr3mo3swhHpQbzOw4u7"; name="test"}
            user       = @{ id = "00u3mo3swhHpQbzOw4u7"}
        }
    }
}

Describe "Cleanup" {
    It 'Removes AuthServer and App' {
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
        $null = Get-OktaAuthorizationServer -Query $authServerName
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/authorizationServers?q=$authServerName" -and $Method -eq 'GET'
                }
    }
    It "Creates a new AuthServer" {
        $null = New-OktaAuthorizationServer -Name $authServerName `
            -Audience "api://oktaposh/api" `
            -Description "OktaPosh Test Authorization Server"
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/authorizationServers" -and $Method -eq 'POST'
                }
    }
    It "Gets Authorization Servers" {
        $null = Get-OktaAuthorizationServer
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/authorizationServers" -and $Method -eq 'GET'
                }
    }
    It "Gets Authorization Server By Id" {
        $null = Get-OktaAuthorizationServer -AuthorizationServerId $vars.authServer.Id
        $null = Get-OktaAuthorizationServer -Query $vars.authServer.Id
        Should -Invoke Invoke-WebRequest -Times 2 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/authorizationServers/$($vars.authServer.Id)" -and $Method -eq 'GET'
                }
        Get-OktaQueryForId | Should -BeTrue
        Set-OktaOption -ApiToken (Get-OktaApiToken) -BaseUri (Get-OktaBaseUri) -UseQueryForId $false
        Get-OktaQueryForId | Should -BeFalse
        $null = Get-OktaAuthorizationServer -Query $vars.authServer.Id
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/authorizationServers?q=$($vars.authServer.Id)" -and $Method -eq 'GET'
                }
        Set-OktaOption -ApiToken (Get-OktaApiToken) -BaseUri (Get-OktaBaseUri) -UseQueryForId $true
        Get-OktaQueryForId | Should -BeTrue
    }
    It "Gets Authorization Server By Query" {
        $null = Get-OktaAuthorizationServer -Query 'test'
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/authorizationServers?q=test" -and $Method -eq 'GET'
                }
    }
    It "Updates an AuthorizationServer" {
        $null = Set-OktaAuthorizationServer -Id $vars.authServer.Id -Name $authServerName `
            -Audience $vars.authServer.audiences[0]
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/authorizationServers/$($vars.authServer.Id)" -and $Method -eq 'PUT'
                }
        $null = Get-OktaAuthorizationServer -AuthorizationServerId $vars.authServer.Id
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/authorizationServers/$($vars.authServer.Id)" -and $Method -eq 'PUT'
                }
    }

    It "Disables Authorization Server" {
        Disable-OktaAuthorizationServer -Id $vars.authServer.Id -Confirm:$false
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/authorizationServers/$($vars.authServer.Id)/lifecycle/deactivate" -and $Method -eq 'POST'
                }
        $result = Get-OktaAuthorizationServer -AuthorizationServerId $vars.authServer.Id
    }

    It "Enables Authorization Server" {
        Enable-OktaAuthorizationServer -Id $vars.authServer.Id
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/authorizationServers/$($vars.authServer.Id)/lifecycle/activate" -and $Method -eq 'POST'
                }
        $result = Get-OktaAuthorizationServer -AuthorizationServerId $vars.authServer.Id
    }
    It "Get OktaOpenIdConfig" {
        Mock -CommandName Invoke-RestMethod -ModuleName OktaPosh
        $null = Get-OktaOpenIdConfig -AuthorizationServerId $vars.authServer.Id
        Should -Invoke Invoke-RestMethod -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/oauth2/$($vars.authServer.Id)/.well-known/openid-configuration" -and $Method -eq $null
                }
    }
    It "Creates new scopes" {
        $null = New-OktaScope -AuthorizationServerId $vars.authServer.id -Name "scope-name"
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/authorizationServers/$($vars.authServer.Id)/scopes" -and $Method -eq 'POST'
                }
    }
    It "Gets scopes" {
        $null = Get-OktaScope -AuthorizationServerId $vars.authServer.id
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/authorizationServers/$($vars.authServer.Id)/scopes" -and $Method -eq 'GET'
                }
    }
    It "Gets scopes by Id" {
        $null = Get-OktaScope -AuthorizationServerId $vars.authServer.id -Query $vars.scope.Id
        $null = Get-OktaScope -AuthorizationServerId $vars.authServer.id -ScopeId $vars.scope.Id
        Should -Invoke Invoke-WebRequest -Times 2 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/authorizationServers/$($vars.authServer.Id)/scopes/$($vars.scope.Id)" -and $Method -eq 'GET'
                }
    }
    It "Updates a scope" {
        $null = Set-OktaScope -AuthorizationServerId $vars.authServer.id -Scope $vars.scope
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/authorizationServers/$($vars.authServer.Id)/scopes/$($vars.scope.id)" -and $Method -eq 'PUT'
                }
    }
    It "Creates new Expression Claim" {
        $null = New-OktaClaim -AuthorizationServerId $vars.authServer.id `
            -Name $claimName -ValueType EXPRESSION -ClaimType ACCESS_TOKEN `
            -Value "app.profile.$claimName" -Scopes "access:token"
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/authorizationServers/$($vars.authServer.Id)/claims" -and $Method -eq 'POST'
                }
    }
    It "Creates new Group Claim" {
        $null = New-OktaClaim -AuthorizationServerId $vars.authServer.id `
            -Name $claimName -ValueType GROUPS -ClaimType ID_TOKEN `
            -GroupFilterType STARTS_WITH -Value "casualty-group" -Scopes "access:token" `

        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/authorizationServers/$($vars.authServer.Id)/claims" -and $Method -eq 'POST'
                }
    }
    It "Gets Claim By Name" {
        $null = Get-OktaClaim -AuthorizationServerId $vars.authServer.id -Query $claimName
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/authorizationServers/$($vars.authServer.Id)/claims" -and $Method -eq 'GET'
                }
    }
    It "Gets Claim By Id" {
        $null = Get-OktaClaim -AuthorizationServerId $vars.authServer.Id -ClaimId $vars.claim.id
        $null = Get-OktaClaim -AuthorizationServerId $vars.authServer.Id -Query $vars.claim.id
        Should -Invoke Invoke-WebRequest -Times 2 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/authorizationServers/$($vars.authServer.Id)/claims/$($vars.claim.id)" -and $Method -eq 'GET'
                }
    }
    It "Updates a Claim" {
        $null = Set-OktaClaim -AuthorizationServerId $vars.authServer.Id -Claim $vars.claim
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/authorizationServers/$($vars.authServer.Id)/claims/$($vars.claim.id)" -and $Method -eq 'PUT'
                }
    }
    It "Adds a policy" {
        $null = New-OktaPolicy -AuthorizationServerId $vars.authServer.Id -Name $policyName -ClientIds $vars.app.Id
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/authorizationServers/$($vars.authServer.Id)/policies" -and $Method -eq 'POST'
                }
        $null = Get-OktaPolicy -AuthorizationServerId  $vars.authServer.Id -Query $policyName
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/authorizationServers/$($vars.authServer.Id)/policies" -and $Method -eq 'GET'
                }
    }
    It "Get a policy by name" {
        $null = Get-OktaPolicy -AuthorizationServerId  $vars.authServer.Id -Query $policyName
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/authorizationServers/$($vars.authServer.Id)/policies" -and $Method -eq 'GET'
                }
    }
    It "Get a policy by Id" {
        $null = Get-OktaPolicy -AuthorizationServerId $vars.authServer.Id -Id $vars.policy.Id
        $null = Get-OktaPolicy -AuthorizationServerId $vars.authServer.Id -Query $vars.policy.Id
        Should -Invoke Invoke-WebRequest -Times 2 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/authorizationServers/$($vars.authServer.Id)/policies/$($vars.policy.Id)" -and $Method -eq 'GET'
                }
    }
    It "Updates a policy" {
        $null = Set-OktaPolicy -AuthorizationServerId $vars.authServer.id -Policy $vars.policy
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/authorizationServers/$($vars.authServer.Id)/policies/$($vars.policy.id)" -and $Method -eq 'PUT'
                }
    }
    It "Adds a rule" {
        $null = New-OktaRule -AuthorizationServerId $vars.authServer.Id `
            -PolicyId $vars.policy.id `
            -Name "Allow $($policyName)" `
            -Priority 1 `
            -GrantTypes client_credentials -Scopes $scopeNames

        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/authorizationServers/$($vars.authServer.Id)/policies/$($vars.policy.Id)/rules" -and $Method -eq 'POST'
                }
    }
    It "Gets a rule by search" {
        $null = Get-OktaRule -AuthorizationServerId $vars.authServer.id -PolicyId $vars.policy.id -Query "Allow $($policyName)"
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/authorizationServers/$($vars.authServer.Id)/policies/$($vars.policy.Id)/rules" -and $Method -eq 'GET'
                }
    }
    It "Gets a rule by Id" {
        $null = Get-OktaRule -AuthorizationServerId $vars.authServer.id -PolicyId $vars.policy.id -Id $vars.rule.id
        $null = Get-OktaRule -AuthorizationServerId $vars.authServer.id -PolicyId $vars.policy.id -Query $vars.rule.id
        Should -Invoke Invoke-WebRequest -Times 2 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/authorizationServers/$($vars.authServer.Id)/policies/$($vars.policy.Id)/rules/$($vars.rule.id)" -and $Method -eq 'GET'
                }
    }
    It "Updates a rule" {
        $null = Set-OktaRule -AuthorizationServerId $vars.authServer.id -PolicyId $vars.policy.id -Rule $vars.rule
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/authorizationServers/$($vars.authServer.Id)/policies/$($vars.policy.Id)/rules/$($vars.rule.id)" -and $Method -eq 'PUT'
                }
    }
    It "Adds SPA Access" {
        $null = New-OktaSpaApplication -Label $spaAppName -RedirectUris $redirectUri -LoginUri "http://login"
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/apps" -and $Method -eq 'POST'
                }

        $null = New-OktaPolicy -AuthorizationServerId $vars.authServer.Id -Name "SPA-$policyName" -ClientIds $vars.spaApp.Id
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/authorizationServers/$($vars.authServer.id)/policies" -and $Method -eq 'POST'
                }

        $null = New-OktaRule -AuthorizationServerId $vars.authServer.Id `
            -PolicyId $policy.id `
            -Name "Allow $($policyName)" `
            -Priority 1 `
            -GrantTypes implicit -Scopes $scopeNames
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/authorizationServers/$($vars.authServer.id)/policies/$($policy.id)/rules" -and $Method -eq 'POST'
                }
    }
    It "Exports an auth server" {
        Mock Out-File -ModuleName OktaPosh -MockWith {}
        $output = (Join-Path ([System.IO.Path]::GetTempPath()) ([Guid]::NewGuid().ToString()) )
        $null = Export-OktaAuthorizationServer -AuthorizationServerId $vars.authServer.id -OutputFolder $output 3>$null
        Remove-Item $output
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/authorizationServers/$($vars.authServer.Id)" -and $Method -eq 'GET'
                }
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/authorizationServers/$($vars.authServer.Id)/claims" -and $Method -eq 'GET'
                }
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/authorizationServers/$($vars.authServer.Id)/policies" -and $Method -eq 'GET'
                }
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/authorizationServers/$($vars.authServer.Id)/scopes" -and $Method -eq 'GET'
                }
        Should -Invoke Out-File -Times 5 -Exactly -ModuleName OktaPosh `
    }
    It "Tests Server JWT Access" {
        $null = Get-OktaAppJwt -ClientId $vars.app.Id -ClientSecret "Test1233!" -Scopes $scopeNames[0] -Issuer $vars.authServer.issuer
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "$($vars.authServer.issuer)/v1/token" -and $Method -eq 'POST'
                }
    }
    It "Tests Server JWT Access With SecureString" {
        $null = Get-OktaAppJwt -ClientId $vars.app.Id -SecureClientSecret (ConvertTo-SecureString "Test1233!" -AsPlainText -Force) -Scopes $scopeNames[0] -Issuer $vars.authServer.issuer
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "$($vars.authServer.issuer)/v1/token" -and $Method -eq 'POST'
                }
    }
    It "Tests Server JWT Access Invalid Parameter" {
        { Get-OktaAppJwt -Scopes $scopeNames[0] 3>$null } | Should -Throw 'Missing required*'
    }
    It "Tests User JWT Access" {
        $null = New-OktaUser -FirstName Wilma -LastName Flintsone -Email $username -Activate -Pw $userPw
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/users?activate=true" -and $Method -eq 'POST'
                }

        $null = Add-OktaApplicationUser -AppId $vars.spaApp.id -UserId $vars.user.Id
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/apps/$($vars.spaApp.id)/users/$($vars.user.Id)" -and $Method -eq 'PUT'
                }


        if ($PSVersionTable.PSVersion.Major -ge 7) {
            $null = Get-OktaJwt -ClientId $vars.spaApp.id `
                        -Issuer $vars.authServer.issuer `
                        -ClientSecret $userPw `
                        -Username $userName `
                        -Scopes $scopeNames[0] `
                        -RedirectUri $redirectUri
            Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                    -ParameterFilter {
                        $Uri -like "*/api/v1/authn" -and $Method -eq 'POST'
                    }
            Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                    -ParameterFilter {
                        $Uri -like "*v1/authorize*"
                    }
        }
    }
    It "Tests User JWT Access with SecureString" {
        if ($PSVersionTable.PSVersion.Major -ge 7) {
            $null = Get-OktaJwt -ClientId $vars.spaApp.id `
                        -Issuer $vars.authServer.issuer `
                        -SecureClientSecret (ConvertTo-SecureString "Test1233!" -AsPlainText -Force) `
                        -Username $userName `
                        -Scopes $scopeNames[0] `
                        -RedirectUri $redirectUri
            Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                    -ParameterFilter {
                        $Uri -like "*/api/v1/authn" -and $Method -eq 'POST'
                    }
            Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                    -ParameterFilter {
                        $Uri -like "*v1/authorize*"
                    }
        }
    }
    It "Tests User JWT Access Invalid arg" {
        if ($PSVersionTable.PSVersion.Major -ge 7) {
            { Get-OktaJwt -Scopes $scopeNames[0] 3> $null } | Should -Throw 'Missing required*'
        }
    }
    It "Removes a Policy Rule" {
        $null = Remove-OktaRule -AuthorizationServerId $vars.authServer.id -PolicyId $vars.policy.id -RuleId $vars.rule.id -Confirm:$false
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/authorizationServers/$($vars.authServer.Id)/policies/$($vars.policy.Id)/rules/$($vars.rule.id)" -and $Method -eq 'DELETE'
                }
    }
    It "Removes a Policy" {
        $null = Remove-OktaPolicy -AuthorizationServerId $vars.authServer.Id -PolicyId $vars.policy.id -Confirm:$false
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/authorizationServers/$($vars.authServer.Id)/policies/$($vars.policy.id)" -and $Method -eq 'DELETE'
                }
    }
    It "Removes a scope" {
        $null = Remove-OktaScope -AuthorizationServerId $vars.authServer.id -ScopeId $vars.scope.id -Confirm:$false
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/authorizationServers/$($vars.authServer.Id)/scopes/$($vars.scope.id)" -and $Method -eq 'DELETE'
                }
    }
    It "Removes a Claim" {
        $null = Remove-OktaClaim -AuthorizationServerId $vars.authServer.Id -ClaimId $vars.claim.id -Confirm:$false
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/authorizationServers/$($vars.authServer.Id)/claims/$($vars.claim.id)" -and $Method -eq 'DELETE'
                }
    }
}

Describe "Cleanup" {
    It 'Removes AuthServer and App' {
        Mock -CommandName Get-OktaAuthorizationServer -ModuleName OktaPosh -MockWith { @{Name="test"}}
        Remove-OktaAuthorizationServer -AuthorizationServerId $vars.authServer.id -Confirm:$false
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/authorizationServers/$($vars.authServer.Id)" -and $Method -eq 'DELETE'
                }
    }
}


