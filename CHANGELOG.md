# Change Log

## 2021-03-18 0.2.4

* Show-Okta will launch browser with the Get-OktaBaseUri
* Support for SPA Apps and Authorization Code flow
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
