# Change Log

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
