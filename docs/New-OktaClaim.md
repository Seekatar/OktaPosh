---
external help file: OktaPosh-help.xml
Module Name: OktaPosh
online version:
schema: 2.0.0
---

# New-OktaClaim

## SYNOPSIS
Create a new Claim on an AuthorizationServer

## SYNTAX

```
New-OktaClaim [-AuthorizationServerId] <String> [-Name] <String> [-ValueType] <String>
 [[-GroupFilterType] <String>] [[-ClaimType] <String>] [-Value] <String> [-Inactive] [[-Scopes] <String[]>]
 [[-AlwayIncludeInToken] <Boolean>] [-Json] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

## EXAMPLES

### EXAMPLE 1
```
PS C:\> New-OktaClaim -AuthorizationServerId ausoqi2fqgcUpYHBS4x6 -Name appName -ValueType EXPRESSION -ClaimType RESOURCE -Value app.profile.appName
```

### EXAMPLE 2
```
PS C:\> New-OktaClaim -AuthorizationServerId ausoqi2fqgcUpYHBS4x6 -Name test -ValueType EXPRESSION -ClaimType RESOURCE -Value app.profile.appName  -Verbose -Scopes "access_token"
```

## PARAMETERS

### -AlwayIncludeInToken
Set to $False to not always include in the Token

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AuthorizationServerId
AuthorizationServerId retrieved from Get-OktaAuthorizationServer

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ClaimType
RESOURCE (Access token) or IDENTITY (Identity Token)

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: RESOURCE, IDENTITY, ACCESS_TOKEN, ID_TOKEN

Required: False
Position: 4
Default value: None
Accept pipeline input: True (ByPropertyName)
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

### -GroupFilterType
For a group-type filter, how to filter the names

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: STARTS_WITH, EQUALS, CONTAINS, REGEX, 

Required: False
Position: 3
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Inactive
Set to add as inactive

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Json
Set to return JSON instead of PSCustomObject

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
Name for new Claim

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Scopes
List of scopes to add to new Claim

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Value
Value to set

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 5
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ValueType
Description

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: EXPRESSION, GROUPS

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
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
Object with Name, ValueType, Value and optional ClaimType, GroupFilterType, Inactive and Scopes

## OUTPUTS

### PSCustomObject
Claiim object

## NOTES

## RELATED LINKS
