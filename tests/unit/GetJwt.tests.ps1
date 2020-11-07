BeforeAll {
    . (Join-Path $PSScriptRoot '../setup.ps1') -Unit
}

# Pester 5 need to pass in TestCases object to pass share
$PSDefaultParameterValues = @{
    "It:TestCases" = @{
        secret          = "thisissecret"
        clientId        = "clientId-123-876-345"
        issuer          = "http://issuer/url"
        scopes          = @("scope1","scope2")
        username        = "user@test.com"
        redirect        = "http://myapp.com"
    }
}
Describe "SetOktaOption" {

    It "Set Okta Option From Env" {
        Set-OktaOption
        Get-OktaBaseUri | Should -Not -Be $null
        Get-OktaApiToken | Should -Not -Be $null
    }
}

Describe "GetsJwts" {

    It "Gets an App Server Jwt" {
        $null = Get-OktaJwt -ClientSecret $secret -ClientId $clientId `
                            -User $null `
                            -Issuer $issuer -Scopes $scopes -GrantType client_credentials
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "$issuer" -and $Method -eq 'POST'
                }
    }
    It "Gets a User Jwt" {
        $null = Get-OktaJwt -User $username -ClientSecret "password" -RedirectUri $redirect  `
                            -ClientId $clientId `
                            -Issuer $issuer -Scopes $scopes -GrantType implicit
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "http://issuer/api/v1/authn" -and $Method -eq 'POST'
                }
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "http://issuer/url/v1/authorize*"
                }
    }
}