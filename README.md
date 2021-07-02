# Okta PowerShell API

![CI](https://github.com/Seekatar/OktaPosh/workflows/CI/badge.svg?branch=main)
![PowerShell Gallery Version](https://img.shields.io/powershellgallery/v/OktaPosh)
![Platforms](https://img.shields.io/powershellgallery/p/OktaPosh)
[![codecov](https://codecov.io/gh/Seekatar/OktaPosh/branch/main/graph/badge.svg?token=XX57WM7GY5)](https://codecov.io/gh/Seekatar/OktaPosh)

This PowerShell module wraps the Okta REST API making it easy to manipulate objects in Okta individually. Use this in a CI/CD pipeline to configure multiple Okta environments consistently. Most of the functionality is also available on the Okta admin site, but not all.

To get the complete list of the module's functions run `Get-Command -Module OktaPosh` (after installing and loading, of course). A summary of all the functions is [here](summary.md)

## Installing

OktaPosh is available in the [PowerShell Gallery](https://www.powershellgallery.com/packages/OktaPosh).  To install it run this command:

``` PowerShell
Install-Module -Name OktaPosh
```

## Quick Examples

The module was design to make getting objects and running then through the pipeline as easy as possible.

```PowerShell
# Delete all test apps (use standard -Confirm:$false to avoid any prompting)
(Get-OktaApplication -q TestApp) | Remove-OktaApplication
```

```PowerShell
# Add all users in an app to a group
$app = Get-OktaApplication -q my-cool-app
$group = Get-OktaGroup -q my-cool-group
Get-OktaApplicationUser -AppId $app.Id | Add-OktaGroupUser -GroupId $group.Id
```

The `tests/integration` folder also has many more examples.

## Comparing Okta Configuration

`ConvertTo-OktaYaml` will get and dump out much of the configuration from Okta into Yaml files that are easy to compare with another system. This is very useful when verifying the configuration in one environment matches another (such as Dev, QA, Prod).

## High Level Functions

The `Build-Okta*` functions and `tests/samples` folder has some high-level functions make adding complex objects a bit easier. There are also some sample scripts used by the my specific situation, but may be useful for others to look at.

## Technical Details

The main Okta API documentation is [here](https://developer.okta.com/docs/reference/) I did find this [OAS Yaml](https://github.com/okta/okta-sdk-java/blob/master/src/swagger/api.yaml), but it doesn't look 100% like the API.

The layout and building of this module and its help is based upon [Donovan Brown's](https://github.com/DarqueWarrior) PowerShell projects, [VSTeam](https://github.com/MethodsAndPractices/vsteam) in particular. Thanks, Donovan!

This module is built and published using GitHub Actions in `.github/workflows`

A helper script `./run.ps1` makes running some of the commands from the GitHub Action locally easier, and some other functionality.
