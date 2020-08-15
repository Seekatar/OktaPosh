---
external help file: OktaPosh-help.xml
Module Name: OktaPosh
online version:
schema: 2.0.0
---

# New-OktaClaim

## SYNOPSIS
Create a new Okta Claim

## SYNTAX

```
New-OktaClaim [-AuthorizationServerId] <String> [-Name] <String> [-ValueType] <String> [[-ClaimType] <String>]
 [-Value] <String> [-Inactive] [[-Scopes] <String[]>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
{{ Fill in the Description }}

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
<!-- #include "./params/authServerId.md" -->

### -Name
Name of new Claim

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

<!-- #include "./params/description.md" -->

### -ClaimType
RESOURCE (Access token) or IDENTITY (Identity Token)

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Value
Value of extra claim

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

<!-- #include "./params/inactive.md" -->

### -Scopes
Parameter description

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

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

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
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

