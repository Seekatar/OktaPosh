# Command Synopses

## OktaPosh Module Functions

To use the module

```PowerShell
Import-Module OktaPosh
```

Function Groups:

* [Application](#Application-Functions)
* [Authorization](#Authorization-Functions)
* [Claim](#Claim-Functions)
* [Group](#Group-Functions)
* [Misc](#Misc-Functions)
* [Policy](#Policy-Functions)
* [Rule](#Rule-Functions)
* [Scope](#Scope-Functions)
* [TrustedOrigin](#TrustedOrigin-Functions)
* [User](#User-Functions)

## Application Functions

Command     | Synopsis
------------|---------|
Add-OktaApplicationGroup | Adds a group to the application
Add-OktaApplicationUser | Add a User to the Application
Disable-OktaApplication | Disable the Application
Enable-OktaApplication | Enable the Application
Get-OktaApplication | Get one or more Applications
Get-OktaApplicationGroup | Get the list of groups attached to the application, or a specific group
Get-OktaApplicationSchema | Get the schema (profile) for the Application
Get-OktaApplicationUser | Get one or more users attached to the application
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
Add-OktaGroupUser | Add a User to a Group
Get-OktaGroup | Get one or more Groups
Get-OktaGroupApp | Get the Applications attached to the Group
Get-OktaGroupUser | Get the Users attached to the Group
New-OktaGroup | Create a new Group
Remove-OktaGroup | Remove a Group
Remove-OktaGroupUser | Remove a User from a Group
Set-OktaGroup | Update a Group's name or description

## Misc Functions

Command     | Synopsis
------------|---------|
addUser | synopsis
Get-OktaApiToken | Get the API token set by Set-OktaOption or from environment, or passed in
Get-OktaAppJwt | Get the JWT for client_credential (server-to-server)
Get-OktaBaseUri | Get the base Uri set by Set-OktaOption or from environment, or passed in
Get-OktaIdentityProvider | Gets Identity Providers. Useful for New-OktaAuthProviderUser
Get-OktaJwt | Get an Okta JWT token for an Application or Okta User
Get-OktaNextUrl | Get the list of NextUrls the module currently knows about.
Get-OktaOpenIdConfig | Get the JSON from the configuration Url for an AuthorizationServer
Get-OktaRateLimit | Get the current rate limit values from the last request
Invoke-OktaApi | Helper for calling the OktaApi. Mainly used internally.
New-OktaAuthProviderUser | Add a user for an Authentication Provider
New-OktaServerApplication | Create a new server-type OAuth Application
New-OktaSpaApplication | Create a new SPA-type OAuth Application
Set-OktaOption | Set OktaOptions for accessing the API
Show-Okta | Launch the browser with the Get-OktaBaseUri, or auth server, or app
Test-OktaNext | Checks to see if -Next will return anything for a give Okta object

## Policy Functions

Command     | Synopsis
------------|---------|
Get-OktaPolicy | Get one of more Policies for an AuthorizationServer
New-OktaPolicy | Create a new Policy on the AuthorizationServer
Remove-OktaPolicy | Remove a Policy from an AuthorizationServer
Set-OktaPolicy | Update an Authorization server's Policy

## Rule Functions

Command     | Synopsis
------------|---------|
Get-OktaRule | Get one or more Rules for an AuthorizationServer and Policy
New-OktaRule | Create a new Rule on the AuthorizationServer's Policy
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
Get-OktaTrustedOrigin | Get one or more TrustedOrigins
New-OktaTrustedOrigin | Create a new TrustedOrigin
Remove-OktaTrustedOrigin | Delete a TrustedOrigin
Set-OktaTrustedOrigin | Update a TrustedOrigin

## User Functions

Command     | Synopsis
------------|---------|
Disable-OktaUser | Disables (deactivates) a user
Enable-OktaUser | Enable (Activate) a user
Get-OktaUser | Get one or more Okta Users
Get-OktaUserApplication | Get the list of Applications for a User
Get-OktaUserGroup | Get a list of Groups for the User
New-OktaUser | Create a new user in Okta, with or without a password
Remove-OktaUser | Remove a user, permanently!
Resume-OktaUser | Resume (Unsuspend) a user
Set-OktaUser | Updates a user object in Okta
Suspend-OktaUser | Suspend a user

---
Generated by New-HelpOutput.ps1 on 03/30/2021 20:24:45
