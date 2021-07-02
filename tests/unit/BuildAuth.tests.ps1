BeforeAll {
    . (Join-Path $PSScriptRoot '../setup.ps1') -Unit
    $params = @{}
    if ($PSVersionTable.PSVersion.Major -ge 7) {
        $params['Depth'] = 10
    }

    Mock -CommandName Get-OktaAuthorizationServer `
        -ParameterFilter { $Query -eq 'found' } `
        -ModuleName OktaPosh `
        -MockWith {
            ConvertFrom-Json @params -InputObject '[{"id":"aus3khmzg4MhFZYuh4x7","name":"found","description":"UI for test","audiences":["https://test/fp-ui"],"issuer":"https://dev-671484.okta.com/oauth2/aus3khmzg4MhFZYuh4x7","issuerMode":"ORG_URL","status":"ACTIVE","created":"2021-06-21T11:33:02.000Z","lastUpdated":"2021-06-21T11:33:02.000Z","credentials":{"signing":{"kid":"VvPxeuzqfEstLJR-vozKrpl0OzRTPhTj-ypnhlZtdaw","rotationMode":"AUTO","lastRotated":"2021-06-21T11:33:02.000Z","nextRotation":"2021-09-19T11:33:02.000Z"}},"_links":{"rotateKey":{"href":"https://dev-671484.okta.com/api/v1/authorizationServers/aus3khmzg4MhFZYuh4x7/credentials/lifecycle/keyRotate","hints":{"allow":["POST"]}},"metadata":[{"name":"oauth-authorization-server","href":"https://dev-671484.okta.com/oauth2/aus3khmzg4MhFZYuh4x7/.well-known/oauth-authorization-server","hints":{"allow":["GET"]}},{"name":"openid-configuration","href":"https://dev-671484.okta.com/oauth2/aus3khmzg4MhFZYuh4x7/.well-known/openid-configuration","hints":{"allow":["GET"]}}],"keys":{"href":"https://dev-671484.okta.com/api/v1/authorizationServers/aus3khmzg4MhFZYuh4x7/credentials/keys","hints":{"allow":["GET"]}},"claims":{"href":"https://dev-671484.okta.com/api/v1/authorizationServers/aus3khmzg4MhFZYuh4x7/claims","hints":{"allow":["GET","POST"]}},"policies":{"href":"https://dev-671484.okta.com/api/v1/authorizationServers/aus3khmzg4MhFZYuh4x7/policies","hints":{"allow":["GET","POST"]}},"self":{"href":"https://dev-671484.okta.com/api/v1/authorizationServers/aus3khmzg4MhFZYuh4x7","hints":{"allow":["GET","DELETE","PUT"]}},"scopes":{"href":"https://dev-671484.okta.com/api/v1/authorizationServers/aus3khmzg4MhFZYuh4x7/scopes","hints":{"allow":["GET","POST"]}},"deactivate":{"href":"https://dev-671484.okta.com/api/v1/authorizationServers/aus3khmzg4MhFZYuh4x7/lifecycle/deactivate","hints":{"allow":["POST"]}}}}]'
        }
    Mock -CommandName Get-OktaAuthorizationServer `
        -ParameterFilter { $Query -eq 'notfound' } `
        -ModuleName OktaPosh `
        -MockWith {
            $null
        }
    Mock -CommandName New-OktaAuthorizationServer `
        -ModuleName OktaPosh `
        -MockWith {
            ConvertFrom-Json @params -InputObject '[{"id":"aus3khmzg4MhFZYuh4x6","name":"found","description":"UI for test","audiences":["https://test/fp-ui"],"issuer":"https://dev-671484.okta.com/oauth2/aus3khmzg4MhFZYuh4x7","issuerMode":"ORG_URL","status":"ACTIVE","created":"2021-06-21T11:33:02.000Z","lastUpdated":"2021-06-21T11:33:02.000Z","credentials":{"signing":{"kid":"VvPxeuzqfEstLJR-vozKrpl0OzRTPhTj-ypnhlZtdaw","rotationMode":"AUTO","lastRotated":"2021-06-21T11:33:02.000Z","nextRotation":"2021-09-19T11:33:02.000Z"}},"_links":{"rotateKey":{"href":"https://dev-671484.okta.com/api/v1/authorizationServers/aus3khmzg4MhFZYuh4x7/credentials/lifecycle/keyRotate","hints":{"allow":["POST"]}},"metadata":[{"name":"oauth-authorization-server","href":"https://dev-671484.okta.com/oauth2/aus3khmzg4MhFZYuh4x7/.well-known/oauth-authorization-server","hints":{"allow":["GET"]}},{"name":"openid-configuration","href":"https://dev-671484.okta.com/oauth2/aus3khmzg4MhFZYuh4x7/.well-known/openid-configuration","hints":{"allow":["GET"]}}],"keys":{"href":"https://dev-671484.okta.com/api/v1/authorizationServers/aus3khmzg4MhFZYuh4x7/credentials/keys","hints":{"allow":["GET"]}},"claims":{"href":"https://dev-671484.okta.com/api/v1/authorizationServers/aus3khmzg4MhFZYuh4x7/claims","hints":{"allow":["GET","POST"]}},"policies":{"href":"https://dev-671484.okta.com/api/v1/authorizationServers/aus3khmzg4MhFZYuh4x7/policies","hints":{"allow":["GET","POST"]}},"self":{"href":"https://dev-671484.okta.com/api/v1/authorizationServers/aus3khmzg4MhFZYuh4x7","hints":{"allow":["GET","DELETE","PUT"]}},"scopes":{"href":"https://dev-671484.okta.com/api/v1/authorizationServers/aus3khmzg4MhFZYuh4x7/scopes","hints":{"allow":["GET","POST"]}},"deactivate":{"href":"https://dev-671484.okta.com/api/v1/authorizationServers/aus3khmzg4MhFZYuh4x7/lifecycle/deactivate","hints":{"allow":["POST"]}}}}]'
        }
    Mock -CommandName Get-OktaScope `
        -ParameterFilter { $Id -eq 'aus3khmzg4MhFZYuh4x7' } `
        -ModuleName OktaPosh `
        -MockWith {
            ConvertFrom-Json @params '[ { "id": "scp3khnu07vd6ieYy4x7", "name": "a", "description": "Added by OktaPosh", "system": false, "metadataPublish": "NO_CLIENTS", "consent": "IMPLICIT", "default": false, "_links": { "self": { "href": "https://dev-671484.okta.com/api/v1/authorizationServers/aus3khmzg4MhFZYuh4x7/scopes/scp3khnu07vd6ieYy4x7", "hints": { "allow": [ "GET", "PUT", "DELETE" ] } } } }, { "id": "scp3khmns1vcGdDoF4x7", "name": "b", "description": "Added by OktaPosh", "system": false, "metadataPublish": "NO_CLIENTS", "consent": "IMPLICIT", "default": false, "_links": { "self": { "href": "https://dev-671484.okta.com/api/v1/authorizationServers/aus3khmzg4MhFZYuh4x7/scopes/scp3khmns1vcGdDoF4x7", "hints": { "allow": [ "GET", "PUT", "DELETE" ] } } } }]'
        }
    Mock -CommandName Get-OktaScope `
        -ParameterFilter { $Id -eq 'aus3khmzg4MhFZYuh4x6' } `
        -ModuleName OktaPosh `
        -MockWith {
            $null
        }
    Mock -CommandName New-OktaScope `
        -ModuleName OktaPosh `
        -MockWith {
            $null
        }
}

Describe "Build Okta Auth server tests" {
    It "Build existing auth server" {
        Build-OktaAuthorizationServer `
            -Name 'found' `
            -Description 'found auth' `
            -Audience 'a' `
            -Scopes 'a','b'

    }
    It "Build existing auth server" {
        Build-OktaAuthorizationServer `
            -Name 'notfound' `
            -Description 'notfound auth' `
            -Audience 'a' `
            -Scopes 'a','b'
    }
}
