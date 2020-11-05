# Okta PowerShell API

![CI](https://github.com/Seekatar/OktaPosh/workflows/CI/badge.svg?branch=main)

This PowerShell module wraps the Okta REST API making it easy to manipulate objects in Okta individually. Use this in a CI/CD pipeline to configure multiple Okta environments consistently. Most of the functionality is also available on the Okta admin site, but not all.

To get the complete list of the module's functions run `Get-Command -Module OktaPosh` (after installing and loading, of course)

## Installing

OktaPosh is available in the [PowerShell Gallery](https://www.powershellgallery.com/packages/OktaPosh).  To install it run this command:

``` PowerShell
Install-Module -Name OktaPosh
```

## Quick Examples

The module was design to make getting objects and running then through the pipeline as easy as possible.

```PowerShell
# Delete all test apps (by default deletes will prompt)
(Get-OktaApplication -q TestApp) | Remove-OktaApplication
```

```PowerShell
# Add all users in an app to a group
$app = Get-OktaApplication -q my-cool-app
$group = Get-OktaGroup -q my-cool-group
Get-OktaApplicationUser -AppId $app.Id | Add-OktaGroupUser -GroupId $group.Id
```

The `tests` folder also has many more examples.

## High Level Functions

The `tests` folder has some high-level functions currently not in the module that add an AuthorizationServer and all of its related objects in one shot. There are also some sample scripts used by the my specific situation, but may be useful for others to look at.

## Technical Details

The main Okta API documentation is [here](https://developer.okta.com/docs/reference/) I did find this [OAS Yaml](https://github.com/okta/okta-sdk-java/blob/master/src/swagger/api.yaml), but it doesn't look 100% like the API.

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

This is run in the build, but you can run it locally like this:

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

### Running The Script Analyzer

This is also run in the build, but you can run it locally like this:

``` powershell
cd OktaPosh
Invoke-ScriptAnalyzer -Path . -Recurse
```
