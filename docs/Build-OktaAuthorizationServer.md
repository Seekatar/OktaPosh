---
external help file: OktaPosh-help.xml
Module Name: OktaPosh
online version:
schema: 2.0.0
---

# Build-OktaAuthorizationServer

## SYNOPSIS
Helper to create an authorization server

## SYNTAX

```
Build-OktaAuthorizationServer [-Name] <String> [-Audience] <String> [-Description] <String>
 [-Scopes] <String[]> [-Quiet] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
This will create an authorization server if it does not exist and add scopes.If it exists, any missing scope are added.
Note that it will not remove scopes that are not in the list.

## EXAMPLES

### Example 1
```powershell
Build-OktaAuthorizationServer `
            -Name testAuthName `
            -Description 'test' `
            -Audience 'api.test.com' `
            -Scopes @('scope:test1','scope:test2')
```

Add a test server if it doesn't exist and ensure it has the two scopes.

## PARAMETERS

### -Audience
Audience value for the AuthorizationServer

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
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

### -Description
Description

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
Name of authorization server

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

### -Scopes
Array of scope names to make sure are on the auth server

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
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

### -Quiet
Do not write informational messages

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
