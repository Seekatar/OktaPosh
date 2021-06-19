---
external help file: OktaPosh-help.xml
Module Name: OktaPosh
online version:
schema: 2.0.0
---

# Test-OktaNext

## SYNOPSIS
Checks to see if -Next will return anything for a give Okta object

## SYNTAX

```
Test-OktaNext [[-ObjectName] <String>]
```

## DESCRIPTION

## EXAMPLES

### Example 1
```
Test-OktaNext users
```

Checks to see if Get-OktaUser -Next will return anything without making a call.

### EXAMPLE 2
```
$app = Get-OktaApplication MyApp
$users = Get-OktaApplicationUser -AppId $app.id -limit 10
while (Test-OktaNext -ObjectName "apps/$($app.id)/users" ) { $users += Get-OktaApplicationUser -AppId $app.id -Next; $users.Count }​​​​​​
$users.credentials.username | Sort-Object
```

Get all the users for MyApp

### EXAMPLE 3
```
$app = Get-OktaApplication MyApp
$users = Get-OktaApplicationUser -AppId $app.id -limit 10
while (Test-OktaNext -ObjectName "apps/$($app.id)/users" ) { $users += Get-OktaApplicationUser -AppId $app.id -Next; $users.Count }​​​​​​
$users.credentials.username | Sort-Object
```

Get all the users for MyApp

## PARAMETERS

### -ObjectName
Base-level object name.
Use tab completion for valid values

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: groups, users, apps, authorizationServers

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

### Bool
True or false

## NOTES

## RELATED LINKS
