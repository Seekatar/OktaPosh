BeforeAll {
    . (Join-Path $PSScriptRoot '../setup.ps1') -Unit
}

# Pester 5 need to pass in TestCases object to pass share
$PSDefaultParameterValues = @{
    "It:TestCases" = @{
        appName        = "PolicyTestApp"
        authServerName = "Okta-Posh-Test"
        scopeNames     = "access:token", "get:item", "save:item", "remove:item"
        claimName      = "test-claim"
        policyName     = "test-policy"
        vars           = @{
            app        = @{ id = "app-987-343-434"}
            claim      = @{ id = "claim-987-343-4234"}
            authServer = @{ id = "server-123-234-234";audiences=@("test")}
            scopes     = @{ id = "scope-123-276-234"}
            policy     = @{ id = "policy-123-234-266"}
            rule       = @{ id = "rule-186-674-234"}
        }
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
    }

    It "Disables Authorization Server" {
        Disable-OktaAuthorizationServer -Id $vars.authServer.Id -Confirm:$false
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/authorizationServers/$($vars.authServer.Id)/lifecycle/deactivate" -and $Method -eq 'POST'
                }
    }

    It "Enables Authorization Server" {
        Enable-OktaAuthorizationServer -Id $vars.authServer.Id
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/authorizationServers/$($vars.authServer.Id)/lifecycle/activate" -and $Method -eq 'POST'
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
    It "Exports an auth server" {
        Mock Out-File -ModuleName OktaPosh -MockWith {}
        $null = Export-OktaAuthorizationServer -AuthorizationServerId $vars.authServer.id -OutputFolder $env:TEMP
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


