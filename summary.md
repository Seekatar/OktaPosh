# Command Synopses

## OktaPosh Module Functions

To use the module

```PowerShell
Import-Module OktaPosh
```

Function Groups:

* [App](#App-Functions)
* [Authorization](#Authorization-Functions)
* [Claim](#Claim-Functions)
* [Group](#Group-Functions)
* [Link](#Link-Functions)
* [Misc](#Misc-Functions)
* [Password](#Password-Functions)
* [PasswordPolicy](#PasswordPolicy-Functions)
* [Policy](#Policy-Functions)
* [Rule](#Rule-Functions)
* [Scope](#Scope-Functions)
* [TrustedOrigin](#TrustedOrigin-Functions)
* [User](#User-Functions)
* [Zone](#Zone-Functions)

## App Functions
 
Command     | Synopsis
------------|---------|
Add-OktaAppGroup | Adds a group to the application
Add-OktaAppUser | Add a User to the Application
Build-OktaSpaApp | Helper to create an spa application
ConvertTo-OktaAppYaml | Get Application objects as Yaml for easy comparison between Okta instances. Note that ConvertTo-OktaYaml calls this.
Disable-OktaApp | Disable the Application
Enable-OktaApp | Enable the Application
Get-OktaApp | Get one or more Applications
Get-OktaAppGroup | Get the list of groups attached to the application, or a specific group
Get-OktaAppSchema | Get the schema (profile) for the Application
Get-OktaAppUser | Get one or more users attached to the application
Remove-OktaApp | Remove an Application. It will disable it first.
Remove-OktaAppGroup | Remove a Group from an Application
Remove-OktaAppSchemaProperty | Remove a Property from a Schema.
Remove-OktaAppUser | Remove a User from the Application
Set-OktaApp | Update an Application
Set-OktaAppProperty | Set an application property
Set-OktaAppSchemaProperty | Set a Property on a Schema
Add-OktaApplicationGroup | Adds a group to the application
Add-OktaApplicationUser | Add a User to the Application
Build-OktaSpaApplication | Helper to create an spa application
ConvertTo-OktaApplicationYaml | Get Application objects as Yaml for easy comparison between Okta instances. Note that ConvertTo-OktaYaml calls this.
Disable-OktaApplication | Disable the Application
Enable-OktaApplication | Enable the Application
Get-OktaAppJwt | Get the JWT for client_credential (server-to-server)
Get-OktaApplication | Get one or more Applications
Get-OktaApplicationGroup | Get the list of groups attached to the application, or a specific group
Get-OktaApplicationSchema | Get the schema (profile) for the Application
Get-OktaApplicationUser | Get one or more users attached to the application
Get-OktaGroupApp | Get the Applications attached to the Group
Get-OktaUserApplication | Get the list of Applications for a User
New-OktaServerApplication | Create a new server-type OAuth Application
New-OktaSpaApplication | Create a new SPA-type OAuth Application
Remove-OktaApplication | Remove an Application. It will disable it first.
Remove-OktaApplicationGroup | Remove a Group from an Application
Remove-OktaApplicationSchemaProperty | Remove a Property from a Schema.
Remove-OktaApplicationUser | Remove a User from the Application
Set-OktaApplication | Update an Application
Set-OktaApplicationProperty | Set an application property
Set-OktaApplicationSchemaProperty | Set a Property on a Schema

## Authorization Functions
 
Command     | Synopsis
------------|---------|
Build-OktaAuthorizationServer | Helper to create an authorization server
ConvertTo-OktaAuthorizationYaml | Get Authorization Server objects as Yaml for easy comparison between Okta instances. Note that ConvertTo-OktaYaml calls this.
Disable-OktaAuthorizationServer | Disable the AuthorizationServer
Enable-OktaAuthorizationServer | Enable the AuthorizationServer
Export-OktaAuthorizationServer | Export the AuthorizationServer and its Claims, Scopes, Policies and their Rules
Get-OktaAuthorizationServer | Get one or more AuthorizationServers
New-OktaAuthorizationServer | Create a new AuthorizationServer
Remove-OktaAuthorizationServer | Remove an Authorization Server. Will disable it first.
Set-OktaAuthorizationServer | Update an AuthorizationServer

## Claim Functions
 
Command     | Synopsis
------------|---------|
Get-OktaClaim | Get one of more Claims for an AuthorizationServer
New-OktaClaim | Create a new Claim on an AuthorizationServer
Remove-OktaClaim | Remove a Claim from an AuthorizationServer
Set-OktaClaim | Update an AuthorizationServer's Claim

## Group Functions
 
Command     | Synopsis
------------|---------|
Add-OktaAppGroup | Adds a group to the application
Get-OktaAppGroup | Get the list of groups attached to the application, or a specific group
Remove-OktaAppGroup | Remove a Group from an Application
Add-OktaApplicationGroup | Adds a group to the application
Add-OktaGroupUser | Add a User to a Group
Get-OktaApplicationGroup | Get the list of groups attached to the application, or a specific group
Get-OktaGroup | Get one or more Groups
Get-OktaGroupApp | Get the Applications attached to the Group
Get-OktaGroupUser | Get the Users attached to the Group
Get-OktaUserGroup | Get a list of Groups for the User
New-OktaGroup | Create a new Group
Remove-OktaApplicationGroup | Remove a Group from an Application
Remove-OktaGroup | Remove a Group
Remove-OktaGroupUser | Remove a User from a Group
Set-OktaGroup | Update a Group's name or description

## Link Functions
 
Command     | Synopsis
------------|---------|
Get-OktaLink | Get the users linked to this one
Get-OktaLinkDefinition | Get one or all a user-to-user link definitions
New-OktaLinkDefinition | Create a new user-to-link definition.
Remove-OktaLink | Remove the link from a user
Remove-OktaLinkDefinition | Remove a link definition
Set-OktaLink | Create a link between two users

## Misc Functions
 
Command     | Synopsis
------------|---------|
ConvertTo-OktaYaml | Get auth, app, trusted origin, and group objects as Yaml for easy comparison between Okta instances
Get-OktaApiToken | Get the API token set by Set-OktaOption or from environment, or passed in
Get-OktaBaseUri | Get the base Uri set by Set-OktaOption or from environment, or passed in
Get-OktaIdentityProvider | Gets Identity Providers. Useful for New-OktaAuthProviderUser
Get-OktaJwt | Get an Okta JWT token for an Application or Okta User
Get-OktaLog | Get Okta system log entries. Defaults to getting 50 within last 10 minutes
Get-OktaNextUrl | Get the list of NextUrls the module currently knows about.
Get-OktaOpenIdConfig | Get the JSON from the configuration Url for an AuthorizationServer
Get-OktaQueryForId | Get the QueryForId setting
Get-OktaRateLimit | Get the current rate limit values from the last request
Invoke-OktaApi | Helper for calling the OktaApi. Mainly used internally.
Set-OktaOption | Set OktaOptions for accessing the API
Show-Okta | Launch the browser with the Get-OktaBaseUri, or auth server, or app
Test-OktaNext | Checks to see if -Next will return anything for a give Okta object

## Password Functions
 
Command     | Synopsis
------------|---------|
Disable-OktaPasswordPolicy | Disables an Okta Policy
Disable-OktaPasswordPolicyRule | Disable a policy rule
Enable-OktaPasswordPolicy | Enables an OktaPolicy
Enable-OktaPasswordPolicyRule | Enable a policy rule
Get-OktaPasswordPolicyRule | Get the rules for an Okta Policy
Remove-OktaPasswordPolicyRule | Remove a policy rule from a policy
Get-OktaPasswordPolicy | Get a password policy
New-OktaPasswordPolicy | Create a new Okta password policy
New-OktaPasswordPolicyRule | Create a new password policy rule for a password policy
Remove-OktaPasswordPolicy | Delete a password policy
Reset-OktaPassword | Reset the password of a user
Reset-OktaPasswordWithAnswer | Reset a user's password given the answer to their current recovery question
Revoke-OktaPassword | Revoke (expire) a users password, forcing them to change it on next login
Set-OktaPassword | Set the user's password to a new value, given the current one.
Set-OktaPasswordPolicy | Update the password policy

## PasswordPolicy Functions
 
Command     | Synopsis
------------|---------|
Disable-OktaPasswordPolicy | Disables an Okta Policy
Disable-OktaPasswordPolicyRule | Disable a policy rule
Enable-OktaPasswordPolicy | Enables an OktaPolicy
Enable-OktaPasswordPolicyRule | Enable a policy rule
Get-OktaPasswordPolicyRule | Get the rules for an Okta Policy
Remove-OktaPasswordPolicyRule | Remove a policy rule from a policy
Get-OktaPasswordPolicy | Get a password policy
New-OktaPasswordPolicy | Create a new Okta password policy
New-OktaPasswordPolicyRule | Create a new password policy rule for a password policy
Remove-OktaPasswordPolicy | Delete a password policy
Set-OktaPasswordPolicy | Update the password policy

## Policy Functions
 
Command     | Synopsis
------------|---------|
Disable-OktaPasswordPolicy | Disables an Okta Policy
Disable-OktaPasswordPolicyRule | Disable a policy rule
Enable-OktaPasswordPolicy | Enables an OktaPolicy
Enable-OktaPasswordPolicyRule | Enable a policy rule
Get-OktaPasswordPolicyRule | Get the rules for an Okta Policy
Remove-OktaPasswordPolicyRule | Remove a policy rule from a policy
Disable-OktaPolicy | Disables an Okta Policy
Disable-OktaPolicyRule | Disable a policy rule
Enable-OktaPolicy | Enables an OktaPolicy
Enable-OktaPolicyRule | Enable a policy rule
Get-OktaPasswordPolicy | Get a password policy
Get-OktaPolicy | Get one of more Policies for an AuthorizationServer
Get-OktaPolicyRule | Get the rules for an Okta Policy
New-OktaPasswordPolicy | Create a new Okta password policy
New-OktaPasswordPolicyRule | Create a new password policy rule for a password policy
New-OktaPolicy | Create a new Policy on the AuthorizationServer
New-OktaPolicyZone | Create a new policy zone
Remove-OktaPasswordPolicy | Delete a password policy
Remove-OktaPolicy | Remove a Policy from an AuthorizationServer
Remove-OktaPolicyRule | Remove a policy rule from a policy
Set-OktaPasswordPolicy | Update the password policy
Set-OktaPolicy | Update an Authorization server's Policy

## Rule Functions
 
Command     | Synopsis
------------|---------|
Disable-OktaPasswordPolicyRule | Disable a policy rule
Enable-OktaPasswordPolicyRule | Enable a policy rule
Get-OktaPasswordPolicyRule | Get the rules for an Okta Policy
Remove-OktaPasswordPolicyRule | Remove a policy rule from a policy
Disable-OktaPolicyRule | Disable a policy rule
Enable-OktaPolicyRule | Enable a policy rule
Get-OktaPolicyRule | Get the rules for an Okta Policy
Get-OktaRule | Get one or more Rules for an AuthorizationServer and Policy
New-OktaPasswordPolicyRule | Create a new password policy rule for a password policy
New-OktaRule | Create a new Rule on the AuthorizationServer's Policy
Remove-OktaPolicyRule | Remove a policy rule from a policy
Remove-OktaRule | Remove a Rule from an AuthorizationServer's Policy
Set-OktaRule | Update an AuthorizationServer's Policy

## Scope Functions
 
Command     | Synopsis
------------|---------|
Get-OktaScope | Get one or more Scopes for an AuthorizationServer
New-OktaScope | Create a new AuthorizationServer Scope
Remove-OktaScope | Remove a Scope from an AuthorizationServer
Set-OktaScope | Update an AuthorizationServer's Scope

## TrustedOrigin Functions
 
Command     | Synopsis
------------|---------|
ConvertTo-OktaTrustedOriginYaml | Get Trusted Origin objects as Yaml for easy comparison between Okta instances. Note that ConvertTo-OktaYaml calls this.
Get-OktaTrustedOrigin | Get one or more TrustedOrigins
New-OktaTrustedOrigin | Create a new TrustedOrigin
Remove-OktaTrustedOrigin | Delete a TrustedOrigin
Set-OktaTrustedOrigin | Update a TrustedOrigin

## User Functions
 
Command     | Synopsis
------------|---------|
Add-OktaAppUser | Add a User to the Application
Get-OktaAppUser | Get one or more users attached to the application
Remove-OktaAppUser | Remove a User from the Application
Add-OktaApplicationUser | Add a User to the Application
Add-OktaGroupUser | Add a User to a Group
Disable-OktaUser | Disables (deactivates) a user
Enable-OktaUser | Enable (Activate) a user
Get-OktaApplicationUser | Get one or more users attached to the application
Get-OktaGroupUser | Get the Users attached to the Group
Get-OktaUser | Get one or more Okta Users
Get-OktaUserApplication | Get the list of Applications for a User
Get-OktaUserGroup | Get a list of Groups for the User
New-OktaAuthProviderUser | Add a user for an Authentication Provider
New-OktaUser | Create a new user in Okta, with or without a password
Remove-OktaApplicationUser | Remove a User from the Application
Remove-OktaGroupUser | Remove a User from a Group
Remove-OktaUser | Remove a user, permanently!
Remove-OktaUserSession | Clear all the user's Okta sessions, forcing the user to re-authenticate
Reset-OktaUserMfa | Resets any MFA for the user
Resume-OktaUser | Resume (Unsuspend) a suspended user
Set-OktaUser | Updates a user object in Okta
Set-OktaUserRecoveryQuestion | Set the recovery question and answser
Suspend-OktaUser | Suspend an active user
Unlock-OktaUser | Unlocks a user who has been locked out

## Zone Functions
 
Command     | Synopsis
------------|---------|
Disable-OktaZone | Disable a zone
Enable-OktaZone | Disable a zone
Get-OktaZone | Get one or more zones by id or usage
New-OktaBlockListZone | Create a new zone to block ips
New-OktaDynamicZone | Create a new dynamic policy for blocklist zone
New-OktaPolicyZone | Create a new policy zone
Remove-OktaZone | Delete a zone
Set-OktaZone | Update an existing zone

---
Generated by New-HelpOutput.ps1 on 11/26/2021 10:38:25
