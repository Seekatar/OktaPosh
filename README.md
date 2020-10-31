# Okta PowerShell API

![CI](https://github.com/Seekatar/OktaPosh/workflows/CI/badge.svg?branch=main)

This PowerShell module wraps the Okta REST API making it easy to manipulate objects in Okta individually.

The first version supported AuthorizationServers and related objects to support the [Client Credentials](https://developer.okta.com/docs/guides/implement-client-creds/use-flow/) flow in Okta.

One action that is currently only available in the API (not the Web UI) is `Set-OktaApplicationProperty`

More functionality will be added as time permits.

## Installing

OktaPosh is available in the [PowerShell Gallery](https://www.powershellgallery.com/packages/OktaPosh).  To install it run this command:

``` PowerShell
Install-Module -Name OktaPosh
```

## Technical Details

The Okta OAS Yaml this is based upon is [here](https://github.com/okta/okta-sdk-java/blob/master/src/swagger/api.yaml)

The layout and building of this module and its help is based upon [Donovan Brown's](https://github.com/DarqueWarrior) PowerShell projects, [VSTeam](https://github.com/MethodsAndPractices/vsteam) in particular. Thanks, Donovan!

This module is built and published using GitHub Actions.

### Updating Help

After editing the help with `#include` platyPS won't be able to update it, so you need to create it anew and merged it.

``` powershell
# one -time
Install-Module -Name platyPS -Scope CurrentUser

Import-Module platyPS
Import-Module .\OktaPosh\OktPosh.psd1 -Force
Update-MarkdownHelp .\docs

# sometimes you may have to generate new doc and compare
New-MarkdownHelp -Module OktaPosh -OutputFolder .\temp\oktaposhdocs
```

### Running Pester v5

``` powershell
cd tests/integration
Invoke-Pester -Configuration @{Output = @{Verbosity='Detailed'}; Run = @{PassThru=$true}; CodeCoverage=@{Enabled=$true;Path='../../OktaPosh/public/*.ps1'}}
```

In code `coverage.xml`

| Property | Description                       |
|----------|-----------------------------------|
| mi       | missed instructions (statements)  |
| ci       | covered instructions (statements) |
| mb       | missed branches                   |
| cb       | covered branches                  |

### Running Script Analyzer

``` powershell
cd OktaPosh
Invoke-ScriptAnalyzer -Path . -Recurse
```
