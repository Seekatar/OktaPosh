# OktaPosh

## OktaPosh

# SHORT DESCRIPTION

Provides access to the Okta REST API and returns objects for easy use in PowerShell piplines.
This is a work in progress and has support for a growing list of Okta objects.

# LONG DESCRIPTION
To call any API, first set the token and baseUri with `Set-OktaOption`

The default parameters are `$env:OKTA_API_TOKEN` and `$env:OKTA_BASE_URI`, which you can set in your
$Profile file etc. to avoid setting it each time the module is loaded

# EXAMPLES
```PowerShell
Set-OktaOption -ApiToken abc123 -BaseUri https://devcccis.oktapreview.com/
Get-OktaAuthorizationServer
```

That will set the Okta API token and base URI for all subsequent calls to Okta. It then makes a call to get all Authorization Servers

# SEE ALSO
Okta API https://developer.okta.com/docs/reference/
Set-OktaOptionh

# KEYWORDS
- Okta
- Posh
- API
- REST

