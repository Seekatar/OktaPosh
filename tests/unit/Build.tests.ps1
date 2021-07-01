BeforeAll {
    . (Join-Path $PSScriptRoot '../setup.ps1') -Unit
    $params = @{}
    if ($PSVersionTable.PSVersion.Major -ge 7) {
        $params['Depth'] = 10
    }

    Mock -CommandName Get-OktaAuthorizationServer `
        -ModuleName OktaPosh `
        -MockWith {
            ConvertFrom-Json @params -InputObject '[{"id":"aus3khmzg4MhFZYuh4x7","name":"Test-AS","description":"UI for test","audiences":["https://test/fp-ui"],"issuer":"https://dev-671484.okta.com/oauth2/aus3khmzg4MhFZYuh4x7","issuerMode":"ORG_URL","status":"ACTIVE","created":"2021-06-21T11:33:02.000Z","lastUpdated":"2021-06-21T11:33:02.000Z","credentials":{"signing":{"kid":"VvPxeuzqfEstLJR-vozKrpl0OzRTPhTj-ypnhlZtdaw","rotationMode":"AUTO","lastRotated":"2021-06-21T11:33:02.000Z","nextRotation":"2021-09-19T11:33:02.000Z"}},"_links":{"rotateKey":{"href":"https://dev-671484.okta.com/api/v1/authorizationServers/aus3khmzg4MhFZYuh4x7/credentials/lifecycle/keyRotate","hints":{"allow":["POST"]}},"metadata":[{"name":"oauth-authorization-server","href":"https://dev-671484.okta.com/oauth2/aus3khmzg4MhFZYuh4x7/.well-known/oauth-authorization-server","hints":{"allow":["GET"]}},{"name":"openid-configuration","href":"https://dev-671484.okta.com/oauth2/aus3khmzg4MhFZYuh4x7/.well-known/openid-configuration","hints":{"allow":["GET"]}}],"keys":{"href":"https://dev-671484.okta.com/api/v1/authorizationServers/aus3khmzg4MhFZYuh4x7/credentials/keys","hints":{"allow":["GET"]}},"claims":{"href":"https://dev-671484.okta.com/api/v1/authorizationServers/aus3khmzg4MhFZYuh4x7/claims","hints":{"allow":["GET","POST"]}},"policies":{"href":"https://dev-671484.okta.com/api/v1/authorizationServers/aus3khmzg4MhFZYuh4x7/policies","hints":{"allow":["GET","POST"]}},"self":{"href":"https://dev-671484.okta.com/api/v1/authorizationServers/aus3khmzg4MhFZYuh4x7","hints":{"allow":["GET","DELETE","PUT"]}},"scopes":{"href":"https://dev-671484.okta.com/api/v1/authorizationServers/aus3khmzg4MhFZYuh4x7/scopes","hints":{"allow":["GET","POST"]}},"deactivate":{"href":"https://dev-671484.okta.com/api/v1/authorizationServers/aus3khmzg4MhFZYuh4x7/lifecycle/deactivate","hints":{"allow":["POST"]}}}}]'
        }
    Mock -CommandName Export-OktaAuthorizationServer `
        -ModuleName OktaPosh `
        -MockWith {
        }
    Mock -CommandName Get-OktaApplication `
        -ParameterFilter { $Query -eq 'found' } `
        -ModuleName OktaPosh `
        -MockWith {
            ConvertFrom-Json @params '{"id":"0oaxotrcezjWplocQ0h7","name":"oidc_client","label":"found","status":"ACTIVE","lastUpdated":"2021-03-18T13:44:44.000Z","created":"2021-03-15T19:16:35.000Z","accessibility":{"selfService":false,"errorRedirectUrl":null,"loginRedirectUrl":null},"visibility":{"autoLaunch":false,"autoSubmitToolbar":false,"hide":{"iOS":true,"web":true},"appLinks":{"oidc_client_link":true}},"features":[],"signOnMode":"OPENID_CONNECT","credentials":{"userNameTemplate":{"template":"${source.login}","type":"BUILT_IN"},"signing":{"kid":"8bPVOa1hmxz7WhdYsNS7l3GSuKdkW1VhLZFoRz1G9Ag"},"oauthClient":{"autoKeyRotation":true,"client_id":"0oaxotrcezjWplocQ0h7","token_endpoint_auth_method":"none"}},"settings":{"app":{},"notifications":{"vpn":{"network":{"connection":"DISABLED"},"message":null,"helpUrl":null}},"notes":{"admin":null,"enduser":null},"oauthClient":{"client_uri":null,"logo_uri":"https://cccis.com/wp-content/uploads/2020/10/CCC-logo.png","redirect_uris":["https://rbr-dev.nonprod.aws.casualty.cccis.com/test-ui/implicit/callback","http://localhost:8008/fp-ui/implicit/callback"],"post_logout_redirect_uris":["https://rbr-dev.nonprod.aws.casualty.cccis.com/test-ui"],"response_types":["code","id_token","token"],"grant_types":["authorization_code","implicit"],"initiate_login_uri":"https://rbr-dev.nonprod.aws.casualty.cccis.com/test-ui","application_type":"browser","consent_method":"REQUIRED","issuer_mode":"ORG_URL","idp_initiated_login":{"mode":"DISABLED","default_scope":[]}}},"_links":{"uploadLogo":{"href":"https://devcccis.oktapreview.com/api/v1/apps/0oaxotrcezjWplocQ0h7/logo","hints":{"allow":["POST"]}},"appLinks":[{"name":"oidc_client_link","href":"https://devcccis.oktapreview.com/home/oidc_client/0oaxotrcezjWplocQ0h7/aln5z7uhkbM6y7bMy0g7","type":"text/html"}],"groups":{"href":"https://devcccis.oktapreview.com/api/v1/apps/0oaxotrcezjWplocQ0h7/groups"},"logo":[{"name":"medium","href":"https://op1static.oktacdn.com/assets/img/logos/default.6770228fb0dab49a1695ef440a5279bb.png","type":"image/png"}],"users":{"href":"https://devcccis.oktapreview.com/api/v1/apps/0oaxotrcezjWplocQ0h7/users"},"deactivate":{"href":"https://devcccis.oktapreview.com/api/v1/apps/0oaxotrcezjWplocQ0h7/lifecycle/deactivate"}}}'
        }
    Mock -CommandName Get-OktaApplication `
        -ParameterFilter { $Query -eq 'notfound' } `
        -ModuleName OktaPosh `
        -MockWith {
            $null
        }
    Mock -CommandName New-OktaSpaApplication `
        -ModuleName OktaPosh `
        -MockWith {
            ConvertFrom-Json @params '{"id":"0oaxotrcezjWplocQ0h7","name":"oidc_client","label":"notfound","status":"ACTIVE","lastUpdated":"2021-03-18T13:44:44.000Z","created":"2021-03-15T19:16:35.000Z","accessibility":{"selfService":false,"errorRedirectUrl":null,"loginRedirectUrl":null},"visibility":{"autoLaunch":false,"autoSubmitToolbar":false,"hide":{"iOS":true,"web":true},"appLinks":{"oidc_client_link":true}},"features":[],"signOnMode":"OPENID_CONNECT","credentials":{"userNameTemplate":{"template":"${source.login}","type":"BUILT_IN"},"signing":{"kid":"8bPVOa1hmxz7WhdYsNS7l3GSuKdkW1VhLZFoRz1G9Ag"},"oauthClient":{"autoKeyRotation":true,"client_id":"0oaxotrcezjWplocQ0h7","token_endpoint_auth_method":"none"}},"settings":{"app":{},"notifications":{"vpn":{"network":{"connection":"DISABLED"},"message":null,"helpUrl":null}},"notes":{"admin":null,"enduser":null},"oauthClient":{"client_uri":null,"logo_uri":"https://cccis.com/wp-content/uploads/2020/10/CCC-logo.png","redirect_uris":["https://rbr-dev.nonprod.aws.casualty.cccis.com/test-ui/implicit/callback","http://localhost:8008/fp-ui/implicit/callback"],"post_logout_redirect_uris":["https://rbr-dev.nonprod.aws.casualty.cccis.com/test-ui"],"response_types":["code","id_token","token"],"grant_types":["authorization_code","implicit"],"initiate_login_uri":"https://rbr-dev.nonprod.aws.casualty.cccis.com/test-ui","application_type":"browser","consent_method":"REQUIRED","issuer_mode":"ORG_URL","idp_initiated_login":{"mode":"DISABLED","default_scope":[]}}},"_links":{"uploadLogo":{"href":"https://devcccis.oktapreview.com/api/v1/apps/0oaxotrcezjWplocQ0h7/logo","hints":{"allow":["POST"]}},"appLinks":[{"name":"oidc_client_link","href":"https://devcccis.oktapreview.com/home/oidc_client/0oaxotrcezjWplocQ0h7/aln5z7uhkbM6y7bMy0g7","type":"text/html"}],"groups":{"href":"https://devcccis.oktapreview.com/api/v1/apps/0oaxotrcezjWplocQ0h7/groups"},"logo":[{"name":"medium","href":"https://op1static.oktacdn.com/assets/img/logos/default.6770228fb0dab49a1695ef440a5279bb.png","type":"image/png"}],"users":{"href":"https://devcccis.oktapreview.com/api/v1/apps/0oaxotrcezjWplocQ0h7/users"},"deactivate":{"href":"https://devcccis.oktapreview.com/api/v1/apps/0oaxotrcezjWplocQ0h7/lifecycle/deactivate"}}}'
        }
    Mock -CommandName Get-OktaPolicy `
        -ParameterFilter { $Query -eq 'found-policy' } `
        -ModuleName OktaPosh `
        -MockWith {
            ConvertFrom-Json @params '{"id":"00p3khodi1pJYyiTv4x7","status":"INACTIVE","name":"CCC-CASReliance-DRE-Policy","description":"Added by OktaPosh","priority":3,"system":false,"conditions":{"clients":{"include":[]}},"created":"2021-06-21T11:37:17.000Z","lastUpdated":"2021-06-29T23:27:57.000Z","_links":{"activate":{"href":"https://dev-671484.okta.com/api/v1/authorizationServers/aus3khnoy9TlHR6OE4x7/policies/00p3khodi1pJYyiTv4x7/lifecycle/activate","hints":{"allow":["POST"]}},"self":{"href":"https://dev-671484.okta.com/api/v1/authorizationServers/aus3khnoy9TlHR6OE4x7/policies/00p3khodi1pJYyiTv4x7","hints":{"allow":["GET","PUT","DELETE"]}},"rules":{"href":"https://dev-671484.okta.com/api/v1/authorizationServers/aus3khnoy9TlHR6OE4x7/policies/00p3khodi1pJYyiTv4x7/rules","hints":{"allow":["GET"]}}},"type":"OAUTH_AUTHORIZATION_POLICY"}'
        }
    Mock -CommandName New-OktaPolicy `
        -ModuleName OktaPosh `
        -MockWith {
            ConvertFrom-Json @params '{"id":"00p3khodi1pJYyiTv4x7","status":"INACTIVE","name":"CCC-CASReliance-DRE-Policy","description":"Added by OktaPosh","priority":3,"system":false,"conditions":{"clients":{"include":[]}},"created":"2021-06-21T11:37:17.000Z","lastUpdated":"2021-06-29T23:27:57.000Z","_links":{"activate":{"href":"https://dev-671484.okta.com/api/v1/authorizationServers/aus3khnoy9TlHR6OE4x7/policies/00p3khodi1pJYyiTv4x7/lifecycle/activate","hints":{"allow":["POST"]}},"self":{"href":"https://dev-671484.okta.com/api/v1/authorizationServers/aus3khnoy9TlHR6OE4x7/policies/00p3khodi1pJYyiTv4x7","hints":{"allow":["GET","PUT","DELETE"]}},"rules":{"href":"https://dev-671484.okta.com/api/v1/authorizationServers/aus3khnoy9TlHR6OE4x7/policies/00p3khodi1pJYyiTv4x7/rules","hints":{"allow":["GET"]}}},"type":"OAUTH_AUTHORIZATION_POLICY"}'
        }
    Mock -CommandName Get-OktaPolicy `
        -ParameterFilter { $Query -eq 'notfound' } `
        -ModuleName OktaPosh `
        -MockWith {
            $null
        }
    Mock -CommandName Get-OktaRule `
        -ParameterFilter { $Query -eq 'Allow found-Policy' } `
        -ModuleName OktaPosh `
        -MockWith {
            ConvertFrom-Json @params '[{"id":"0pr3khpqqgezen3Lx4x7","status":"ACTIVE","name":"Allow CCC-CASDataCapture-SPA-Policy","priority":1,"created":null,"lastUpdated":null,"system":false,"conditions":{"people":{"users":{"include":[],"exclude":[]},"groups":{"include":["EVERYONE"],"exclude":[]}},"grantTypes":{"include":["implicit","authorization_code"]},"scopes":{"include":["*"]}},"actions":{"token":{"accessTokenLifetimeMinutes":60,"refreshTokenLifetimeMinutes":0,"refreshTokenWindowMinutes":10080}},"_links":{"self":{"href":"https://dev-671484.okta.com/api/v1/authorizationServers/aus3khpmpkPFfJtd04x7/policies/00p3khmxad6nvHmCs4x7/rules/0pr3khpqqgezen3Lx4x7","hints":{"allow":["GET","PUT","DELETE"]}},"deactivate":{"href":"https://dev-671484.okta.com/api/v1/authorizationServers/aus3khpmpkPFfJtd04x7/policies/00p3khmxad6nvHmCs4x7/rules/0pr3khpqqgezen3Lx4x7/lifecycle/deactivate","hints":{"allow":["POST"]}}},"type":"RESOURCE_ACCESS"}]'
        }
    Mock -CommandName New-OktaRule `
        -ModuleName OktaPosh `
        -MockWith {
            ConvertFrom-Json @params '[{"id":"0pr3khpqqgezen3Lx4x7","status":"ACTIVE","name":"Allow CCC-CASDataCapture-SPA-Policy","priority":1,"created":null,"lastUpdated":null,"system":false,"conditions":{"people":{"users":{"include":[],"exclude":[]},"groups":{"include":["EVERYONE"],"exclude":[]}},"grantTypes":{"include":["implicit","authorization_code"]},"scopes":{"include":["*"]}},"actions":{"token":{"accessTokenLifetimeMinutes":60,"refreshTokenLifetimeMinutes":0,"refreshTokenWindowMinutes":10080}},"_links":{"self":{"href":"https://dev-671484.okta.com/api/v1/authorizationServers/aus3khpmpkPFfJtd04x7/policies/00p3khmxad6nvHmCs4x7/rules/0pr3khpqqgezen3Lx4x7","hints":{"allow":["GET","PUT","DELETE"]}},"deactivate":{"href":"https://dev-671484.okta.com/api/v1/authorizationServers/aus3khpmpkPFfJtd04x7/policies/00p3khmxad6nvHmCs4x7/rules/0pr3khpqqgezen3Lx4x7/lifecycle/deactivate","hints":{"allow":["POST"]}}},"type":"RESOURCE_ACCESS"}]'
        }
    Mock -CommandName Get-OktaRule `
        -ParameterFilter { $Query -eq 'notfound' } `
        -ModuleName OktaPosh `
        -MockWith {
            $null
        }
    Mock -CommandName Set-OktaApplication `
        -ModuleName OktaPosh `
        -MockWith {
            ConvertFrom-Json @params '[{"id":"0oa3khma4jMjfF1Z34x7","name":"oidc_client","label":"found","status":"ACTIVE","lastUpdated":"2021-06-21T11:35:50.000Z","created":"2021-06-21T11:35:50.000Z","accessibility":{"selfService":false,"errorRedirectUrl":null,"loginRedirectUrl":null},"visibility":{"autoSubmitToolbar":false,"hide":{"iOS":true,"web":true},"appLinks":{"oidc_client_link":true}},"features":[],"signOnMode":"OPENID_CONNECT","credentials":{"userNameTemplate":{"template":"${source.login}","type":"BUILT_IN"},"signing":{"kid":"PsO-MfjE4aiqf1MYxq4NNQvqL0xM1uKTO69C059XTEA"},"oauthClient":{"autoKeyRotation":true,"client_id":"0oa3khma4jMjfF1Z34x7","token_endpoint_auth_method":"none"}},"settings":{"app":{},"notifications":{"vpn":{"network":{"connection":"DISABLED"},"message":null,"helpUrl":null}},"oauthClient":{"client_uri":null,"logo_uri":null,"redirect_uris":["https://rbr-qa.prod.aws.test.is.com/dc-ui/implicit/callback"],"post_logout_redirect_uris":["https://rbr-qa.prod.aws.test.is.com/dc-ui"],"response_types":["token","id_token","code"],"grant_types":["implicit","authorization_code"],"initiate_login_uri":"https://rbr-qa.prod.aws.test.is.com/dc-ui","application_type":"browser","consent_method":"REQUIRED","issuer_mode":"ORG_URL","idp_initiated_login":{"mode":"DISABLED","default_scope":[]}}},"_links":{"appLinks":[{"name":"oidc_client_link","href":"https://dev-671484.okta.com/home/oidc_client/0oa3khma4jMjfF1Z34x7/aln177a159h7Zf52X0g8","type":"text/html"}],"groups":{"href":"https://dev-671484.okta.com/api/v1/apps/0oa3khma4jMjfF1Z34x7/groups"},"logo":[{"name":"medium","href":"https://ok11static.oktacdn.com/assets/img/logos/default.6770228fb0dab49a1695ef440a5279bb.png","type":"image/png"}],"users":{"href":"https://dev-671484.okta.com/api/v1/apps/0oa3khma4jMjfF1Z34x7/users"},"deactivate":{"href":"https://dev-671484.okta.com/api/v1/apps/0oa3khma4jMjfF1Z34x7/lifecycle/deactivate"}}}]'
        }

}

Describe "Build Okta App tests" {
    It "Tests New App" {
        Build-OktaSpaApplication `
            -Label 'found' `
            -RedirectUris 'a','b' `
            -LoginUri 'c' `
            -PostLogoutUris 'd','e' `
            -SignOnMode "OPENID_CONNECT" `
            -GrantTypes 'Implicit','authorization_code' `
            -Scopes 'a','b' `
            -AuthServerId 'aus3khpqqgezen3Lx4x7'

    }
    It "Tests New App" {
        Build-OktaSpaApplication `
            -Label 'notFound' `
            -RedirectUris 'a','b' `
            -LoginUri 'c' `
            -PostLogoutUris 'd','e' `
            -SignOnMode "OPENID_CONNECT" `
            -GrantTypes 'Implicit','authorization_code' `
            -Scopes 'a','b' `
            -AuthServerId 'aus3khpqqgezen3Lx4x7'

    }
}
