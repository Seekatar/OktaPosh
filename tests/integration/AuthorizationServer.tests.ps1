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
        $script:authServer = New-OktaAuthorizationServer -Name $authServerName `
            -Audiences "api://oktaposh/api" `
            -Issuer "$(Get-OktaBaseUri)/oauth2/default" `
            -Description "OktaPosh Test Authorization Sserver"
        $script:authServer | Should -Not -Be $null
    }

    It "Checks for existing scope" {
        $existingScopes = Get-OktaScope -AuthorizationServerId $script:authServer.id | Select-Object -ExpandProperty name
        $existingScopes | Should -Be $null
    }

    It "Creates new scopes" {
        $newScopes = $scopes | New-OktaScope -AuthorizationServerId $script:authServer.id
        $newScopes.Count | Should -Be $scopes.Count
    }

    It "Checks for existing Claim" {
        $claim = Get-OktaClaim -AuthorizationServerId $script:authServer.id -Query $claimName
        $claim | Should -Be $null
    }

    It "Creates new Claim" {
        $claim = New-OktaClaim -AuthorizationServerId $script:authServer.id `
            -Name $claimName -ValueType EXPRESSION -ClaimType RESOURCE `
            -Value "app.profile.$claimName" -Scopes "access:token"
        $claim | Should -Not -Be $null
    }

    It "Gets Authorization Servers" {
        $result = Get-OktaAuthorizationServer
        $result | Should -Not -Be $null
        $result.Count | Should -BeGreaterThan 0
    }

    It "Gets Authorization Server By Id" {
        $result = Get-OktaAuthorizationServer -AuthorizationServerId $script:authServer.Id
        $result | Should -Not -Be $null
        $result.Id | Should -Be $script:authServer.Id
    }

    It "Gets Authorization Server By Query" {
        $result = Get-OktaAuthorizationServer -Query 'test'
        $result | Should -Not -Be $null
        $result.Id | Should -Be $script:authServer.Id
    }

    AfterAll {
        Remove-OktaAuthorizationServer -AuthorizationServerId $script:authServer.Id -Confirm:$false
    }
}

