---
external help file: OktaPosh-help.xml
Module Name: OktaPosh
online version:
schema: 2.0.0
---

# New-OktaAuthProviderUser

## SYNOPSIS
Add a user for an Authentication Provider

## SYNTAX

```
New-OktaAuthProviderUser [-FirstName] <String> [-LastName] <String> [-Email] <String> [[-Login] <String>]
 [-ProviderType] <String> [[-ProviderName] <String>] [[-GroupIds] <String[]>] [-Activate] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
For users automatically added via an Authentication Provider, this allows you to add them before the first login.
So you can add them to groups and apps, etc.
Group Rules can do something similar.

## EXAMPLES

### Example 1
```
New-OktaAuthProviderUser -FirstName Fred -LastName Flintstone -Email fflintstone@myco.com -Type FEDERATION -name Corporate-AD
```

Add's domain user fflintstone@myco.com to Okta.

### Example 2
$groupIds = (Get-OktaGroup -q Test).id


```
$profile = [PSCustomObject]@{
    given_name = 'Sheryl'
    family_name = 'Limor'
    email = 'Sheryl_Limor@test.com'
}
$profile | New-OktaAuthProviderUser -ProviderType LDAP -ProviderName AZURAD -GroupIds $groupIds
```

Add user from an object, and adding to all Test groups at the same time

## PARAMETERS

### -Activate
Set to Activate (Enable) to use on add

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Email
Email address

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -FirstName
First name

```yaml
Type: String
Parameter Sets: (All)
Aliases: given_name

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -GroupIds
Optional array of groups to add the user to

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -LastName
Last name

```yaml
Type: String
Parameter Sets: (All)
Aliases: family_name

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Login
Login, defaults to Email

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ProviderName
Directory instance name as the name property for ACTIVE_DIRECTORY or LDAP providers.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProviderType
Type of Authentication Provider, use tab to see valid values

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: OKTA, ACTIVE_DIRECTORY, LDAP, FEDERATION, SOCIAL, IMPORT

Required: True
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### PSCustomObject
User profile object with FirstName, LastName, Email, and optional Login

## OUTPUTS

### PSCustomObject
User object

### System.Object
## NOTES

## RELATED LINKS
