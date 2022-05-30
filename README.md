# Okta PowerShell API

![CI](https://github.com/Seekatar/OktaPosh/workflows/CI/badge.svg?branch=main)
![PowerShell Gallery Version](https://img.shields.io/powershellgallery/v/OktaPosh)
![Platforms](https://img.shields.io/powershellgallery/p/OktaPosh)
[![codecov](https://codecov.io/gh/Seekatar/OktaPosh/branch/main/graph/badge.svg?token=XX57WM7GY5)](https://codecov.io/gh/Seekatar/OktaPosh)

This PowerShell module wraps the Okta REST API making it easy to manipulate objects in Okta individually. It really shines when used in a CI/CD pipeline to configure multiple Okta environments consistently.

Most of the functionality is also available on the Okta admin site, but not all. If you are manually configuring Okta on the web, you probably have a long, manual checklist and can easily make a mistake. Even if you manually configure Okta, you can use the [compare](#comparing-okta-configuration) functionality of OktaPosh to validate your environments are configured the same way.

OktaPosh has CRUD operations on the most-used Okta objects, like authorization servers, applications, users, etc. A summary of all the functions is [here](summary.md).

To get the complete list of the module's functions run `Get-Command -Module OktaPosh` (after installing and loading, of course).

## Installing

OktaPosh is available in the [PowerShell Gallery](https://www.powershellgallery.com/packages/OktaPosh). To install it run this command:

``` PowerShell
Install-Module -Name OktaPosh
```

## Quick Examples

The module was designed to make getting objects and running them through the pipeline as easy as possible.

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

## Importing Okta Configuration

`Import-OktaConfiguration` takes a JSON file that describes an authorization server, applications and all their related objects, and will create or update them in Okta. It will check to see if the item exists and will add it if it doesn't. Some objects (apps), will be updated if they exist.

To make editing the JSON easier, there are several typical examples in the `tests/samples/import` folder. Also, `schemas/configuration-schema.json` can be set as the `$schema` property in the JSON file and VS Code will give you intellisense for adding elements (Ctrl+Space), and help on hover for each item.

The function can import the following:

* Authorization Server
  * Scopes
  * Claims
  * Policies
    * Rules
* Groups
  * Optionally create Scope and Claim on auth server
* Server Apps for server-to-server apps and auth
  * Attach Scopes
  * Attach Groups
* SPA Apps for SPA applications and auth
  * Attach Scopes
  * Attach Groups

### Variables

Since the values in each deployment environment may differ from one to another, you can use a simple variable substitution within the JSON to avoid copying config files. Variables use a mustache-like syntax as shown below:

```json
"variables": {
  "ui-path": "myApp-ui"
}
...
"audience": "https://myapp/{{ ui-path }}",
```

`{{ ui-path }}` will be replaced with a value in `variables` or from the `-Variables` hash table parameter.

The `variables` property in the JSON has the default values, which can also be useful if you have a constant value repeated and want that in one place. The `-Variables` parameter to `Import-OktaConfiguration` overrides and adds the `variables` when doing the substitutions.

If you have a large list that differs, you can create a separate JSON element, or use a filename as the variable's value, and the entire file's content will be dropped in. See the `many-groups-ui-app.json` for an example and the `Build-TestOutput.ps1` file that calls it.

```json
"variables": {
  "groupObjects": "groups.json"
}
...
"groups": [
    "{{ groupObjects }}"
],

```

In this case the value of `groupObjects` is `groups.json` and that file exists alongside the json file and has the values for all the groups.

```json
{
  "name": "GroupName1",
  "scope": "group-scope1"
},
{
  "name": "GroupName2",
  "scope": "group-scope2"
},
...
```

To make sure your variables are correct you can use the `-DumpConfig` switch which will do the variable substitution, and write the content to the output stream.

You can optionally append to an array of items that may already have some values. See the `ui-app.json` sample for how it has several `{{ additional* }}` substitutions. Here's one example.

```json
"variables": {
    "additionalRedirect": "",
},
...
"redirectUris": [
    "https://rbr{{ domainSuffix }}.myportal.com/{{ ui-path }}/implicit/callback",
    "https://rbr{{ domainSuffix }}.{{ cluster }}.com/{{ ui-path }}/implicit/callback",
    "{{ additionalRedirect }}"
],
```

By default nothing is added since the value in variables is empty, but you can override variables on the when calling the function to override and add additional values for one environment.

## Comparing Okta Configuration

`ConvertTo-OktaYaml` will get and dump out much of the configuration from Okta into Yaml files that are easy to compare with another system. This is very useful when verifying the configuration in one environment matches another (such as Dev, QA, Prod).

## High Level Functions

The `Build-Okta*` functions and `tests/samples` folder has some high-level functions that make adding complex objects a bit easier. These are now mainly subsumed by the `Import-OktaConfiguration` function discussed [above](#importing-okta-configuration). There are also some sample scripts used by my specific situation, but may be useful for others to look at.

## Technical Details

The main Okta API documentation is [here](https://developer.okta.com/docs/reference/) I did find this [OAS Yaml](https://github.com/okta/okta-sdk-java/blob/master/src/swagger/api.yaml), but it doesn't look 100% like the API.

The layout and building of this module and its help is based upon [Donovan Brown's](https://github.com/DarqueWarrior) PowerShell projects, [VSTeam](https://github.com/MethodsAndPractices/vsteam) in particular. Thanks, Donovan!

This module is built and published using GitHub Actions in `.github/workflows`

A helper script `./run.ps1` makes running some of the commands from the GitHub Action locally easier, and some other functionality.
