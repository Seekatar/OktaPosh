# Change Log

## 2020-10-25

* All `Get-*` functions have `-Json` switch to return raw JSON instead of PSCustomObject
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
