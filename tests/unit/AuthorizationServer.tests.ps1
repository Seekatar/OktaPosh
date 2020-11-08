BeforeAll {
    . (Join-Path $PSScriptRoot '../setup.ps1') -Unit
}

# Pester 5 need to pass in TestCases object to pass share
$PSDefaultParameterValues = @{
    "It:TestCases" = @{
        testAppName     = "Test-API-App" # must exist
        username        = "wflintstone@mailinator.com"
        appName         = "test-policy-app"
        spaAppName      = "test-spa-app"
        userPw          = "Test123!"
        authServerName = "Okta-Posh-Test"
        scopeNames     = "access:token", "get:item", "save:item", "remove:item"
        claimName      = "test-claim"
        policyName     = "test-policy"
        redirectUri     = "http://gohome"
        policy         = @{ id = "policy-123-4675-67"}
        vars           = @{
            app        = @{ id = "app-987-343-434"}
            spaApp     = @{ id = "SpaApp-987-343-434"}
            claim      = @{ id = "claim-987-343-4234"}
            authServer = @{ id = "server-123-234-234";audiences=@("test");issuer="http://issuer"}
            scopes     = @{ id = "scope-123-276-234"}
            policy     = @{ id = "policy-123-234-266"}
            rule       = @{ id = "rule-186-674-234"}
            user       = @{ id = "user-186-674-234"}
        }
    }
}

Describe "Setup" {
    It 'Get API App' {

        Set-OktaOption
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
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/authorizationServers/$($vars.authServer.Id)" -and $Method -eq 'GET'
                }
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
            -Description "new description" `
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
    It "Creates new Claim" {
        $null = New-OktaClaim -AuthorizationServerId $vars.authServer.id `
            -Name $claimName -ValueType EXPRESSION -ClaimType RESOURCE `
            -Value "app.profile.$claimName" -Scopes "access:token"
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
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/authorizationServers/$($vars.authServer.Id)/claims/$($vars.claim.id)" -and $Method -eq 'GET'
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
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/authorizationServers/$($vars.authServer.Id)/policies/$($vars.policy.Id)" -and $Method -eq 'GET'
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
    It "Tests Server JWT Access" {
        $null = Get-OktaAppJwt -ClientId $vars.app.Id -ClientSecret "Test1233!" -Scopes $scopeNames[0] -Issuer $vars.authServer.issuer
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "$($vars.authServer.issuer)/v1/token" -and $Method -eq 'POST'
                }
    }
    # It "Adds SPA Access" {
    #     $null = New-OktaSpaApplication -Label $spaAppName -RedirectUris $redirectUri -LoginUri "http://login"
    #     Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
    #             -ParameterFilter {
    #                 $Uri -like "*/apps" -and $Method -eq 'POST'
    #             }

    #     $null = New-OktaPolicy -AuthorizationServerId $vars.authServer.Id -Name "SPA-$policyName" -ClientIds $vars.spaApp.Id
    #     Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
    #             -ParameterFilter {
    #                 # Write-Warning "1>> $method $uri"
    #                 # Write-Warning "1>> */authorizationServers/$($vars.authServer.id)/policies"
    #                 # $Uri -like "*/authorizationServers" # /$($vars.authServer.id)/policies"# -and $Method -eq 'POST'
    #                 $true
    #             }

    #     $null = New-OktaRule -AuthorizationServerId $vars.authServer.Id `
    #         -PolicyId $policy.id `
    #         -Name "Allow $($policyName)" `
    #         -Priority 1 `
    #         -GrantTypes implicit -Scopes $scopeNames
    #     Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
    #             -ParameterFilter {
    #                 Write-Warning "2>> $method $uri"
    #                 Write-Warning "*/authorizationServers/$($vars.authServer.id)/policies/$($policy.id)/rules"
    #                 $Uri -like "*/authorizationServers/$($vars.authServer.id)/policies/$($policy.id)/rules" -and $Method -eq 'POST'
    #             }
    # }
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
                        -Username $userName -Scopes $scopeNames[0] `
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
    It "Exports an auth server" {
        Mock Out-File -ModuleName OktaPosh -MockWith {}
        $null = Export-OktaAuthorizationServer -AuthorizationServerId $vars.authServer.id -OutputFolder ([System.IO.Path]::GetTempPath())
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
    It "Removes a Claim By Id" {
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


