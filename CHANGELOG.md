# Change Log

## 2022-05-22 0.5.0

* New functions
  * Import-OktaUser to allow importing users with a CSV

## 2021-12-31 0.4.1

* New functions
  * Import-OktaConfiguration for easier CI/CD. This has a superset of the Build-OktaSpaApplication and Build-OktaAuthorizationServer functions
  * Set-OktaReadOnly can disable any non-GET API calls in case you connect to a system you don't want to accidentally write to. Not that this has ever happened before.
* Updates
  * Set-Options has -WarnIfMore switch that will kick out a warning message if more data is available when getting items
  * Change Export-OktaAuthorizationServer to export formatted JSON instead of one line for easier comparing
  * Change Export-OktaAuthorizationServer to export more details about scopes and rules
  * New-Okta*Application Inactive switch obsolete since Okta always added as active.
  * ConvertTo-OktaYaml now takes array for app name query and regular expression for TrustedOrigins
* Fixes
  * Fix ConvertTo-OktaApplicationYaml to get all applications if more than default Limit of 20, and get all groups
  * Fix ConvertTo-OktaAuthorizationYaml in instance where label was missing, and claim sorting by type
  * Fix ConvertTo-OktaYaml to exclude directories starting with '.' to avoid warning
  * Fix Export-OktaAuthorizationServer for policies with rules.

## 2021-08-01 0.3.1

* Get-OktaLog better -Since and -Until support for d, h, m, s
* Invoke-OktaApi has -AdditionalHeaders
* Disable-OktaUser has -Async
* Remove-OktaUser has -Async
* New functions
  * Remove-OktaUserSession
  * Reset-OktaPassword
  * Reset-OktaPasswordWithAnswer
  * Reset-OktaUserMfa
  * Revoke-OktaPassword
  * Set-OktaPassword
  * Set-OktaUserRecoveryQuestion
  * Unlock-User

## 2021-07-01 0.3.0

* New helper functions
  * Build-OktaAuthorizationServer
  * Build-OktaApplication
* New functions for linking users
  * Get-OktaLink
  * Get-OktaLinkDefinition
  * New-OktaLinkDefinition
  * Remove-OktaLink
  * Remove-OktaLinkDefinition
  * Set-OktaLink
* All Get-Okta* function with a -Query parameter now will use heuristics to determine if it's an id. This may be turned off with `Set-OktaQueryForId $false`
* Add unit test for yaml
* More parameter index cleanup
* Add -Until to Get-OktaLog

## 2021-06-21 0.2.9

* Fix for yaml for newlines and trusted origins

## 2021-06-19 0.2.8

* New functions
  * ConvertTo-Okta*Yaml functions to generate easily compared configuration
  * *-OktaZone
  * Get-OktaLog
  * *-OktaPasswordPolicy
  * *-OktaPasswordPolicyRule

## 2021-03-27 0.2.7

* Update Test-OktaNext to work for any type of object. Tab completion dynamically shows available ObjectNames. See about_oktaposh_paging
* For functions with -Next there's -NoWarn to suppress warning with no results returned
* Parameter updates for ambiguous parameter sets

## 2021-03-27 0.2.5

* Add Set-OktaUser
* Add auth and app to Show-Okta
* Fix for passing secure strings

## 2021-03-19 0.2.4

* Show-Okta will launch browser with the Get-OktaBaseUri
* Support for SPA Apps and Authorization Code flow in New-OktaSpaApp
* New auth server functions
  * Set-OktaScope
  * Remove-OktaScope
  * Set-OktaPolicy
  * Remove-OktaPolicy
  * Set-OktaRule
  * Remove-OktaRule

## 2021-02-17 0.2.3

* New-OktaAuthProviderUser remove unusable NextLogin parameter since didn't make sense
* New-OktaAuthUser added support for more parameters
  * GroupIds
  * NextLogin
  * RecoveryQuestion
  * RecoveryAnswer
* Note that GroupIds is limited to a max of 20 in the API and enforced by parameter validation now

## 2020-12-09 0.2.1

* Add retry logic for rate limit, and override switch of `Invoke-OktaApi`

## 2020-11-23 0.2.0

* Authorization Server Functions
  * Fixes for Export-OktaAuthorizationServer
* User Functions
  * New-OktaAuthProviderUser added Activate and NextLogin parameters. The former can avoid emails sent on add by calling Enable-OktaUser afterwards.
  * New-OktaUser added pw parameter
  * Disable-OktaUser
  * Enable-OktaUser
  * Suspend-OktaUser
  * Resume-OktaUser
* Misc
  * Set-OktaOption returns boolean indicating success
  * Invoke-OktaApi added NotFoundOk parameter, PS v5 fixes

## 2020-11-09

* Greatly increase test code coverage
* Fixes for Get-OktaJwt, split into two functions, Get-OktaJwt only works on PS v7
* PowerShell v5 compatibility fixes
* Add run.ps1 to more easily invoke commands locally

## 2020-11-05

* Replace less that useful -After parameter with -Next switch for Gets that have -Limit and support it
* User Functions
  * Get-OktaUserApplication
  * Get-OktaUserGroup
  * New-OktaAuthProviderUser
* Misc
  * Get-OktaIdentityProvider

## 2020-11-02

* User Functions
  * Add-OktaApplicationUser
  * Add-OktaGroupUser
  * Remove-OktaApplicationUser
  * Remove-OktaGroupUser

## 2020-10-31

* All `Get-*` functions have `-Json` switch to return raw JSON instead of PSCustomObject
* Get-OktaJwt really works now, and will be api and user tokens.
* New Functions
  * Applications
    * Disable-OktaApplication
    * Enable-OktaApplication
    * Set-OktaApplication
    * New-OktaSpaApplication
  * Authorization Servers
    * Export-OktaAuthorizationServer
    * Get-OktaOpenIdConfig
  * Claims
    * Remove-OktaClaim
  * Groups & Users
    * Add-OktaApplicationGroup
    * Get-OktaApplicationGroup
    * Get-OktaApplicationUser
    * Get-OktaGroupApp
    * Get-OktaGroupUser
    * Remove-OktaApplicationGroup
  * TrustedDomains
    * Get-OktaTrustedOrigin
    * New-OktaTrustedOrigin
    * Remove-OktaTrustedOrigin
    * Set-OktaTrustedOrigin
  * Schemas (Profiles)
    * Get-OktaApplicationSchema
    * Remove-OktaApplicationSchemaProperty
    * Set-OktaApplicationSchemaProperty
  * Users
    * Add-OktaUser
    * Get-OktaUser
    * Remove-OktaUser

## 2020-09-12

* New Functions
  * Get-OktaRateLimit
  * Disable-OktaAuthorizationServer
  * Enable-OktaAuthorizationServer
