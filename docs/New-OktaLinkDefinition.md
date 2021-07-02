---
external help file: OktaPosh-help.xml
Module Name: OktaPosh
online version: https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
schema: 2.0.0
---

# New-OktaLinkDefinition

## SYNOPSIS
Create a new user-to-link definition.

## SYNTAX

```
New-OktaLinkDefinition [-PrimaryTitle] <String> [-PrimaryName <String>] [-PrimaryDescription <String>]
 [-AssociatedTitle] <String> [-AssociatedName <String>] [-AssociatedDescription <String>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Links are one-to-many relationships with a primary and associated part. For example manager, employee where a manager will have many employees and an employee will have only one manager.

## EXAMPLES

### Example 1
```powershell
New-OktaLinkDefinition -PrimaryTitle boss -PrimaryName TheBoss -AssociatedTitle minon -PrimaryDescription WorkerBee
```

Create a link definition 'boss' with the primary called 'boss' and associated called 'minon'

## PARAMETERS

### -AssociatedDescription
Optional associated description

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AssociatedName
Optional associated name, will be set to AssociatedTitle if not supplied

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AssociatedTitle
Title of the associated part of the link

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

### -PrimaryDescription
Optional primary description

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PrimaryName
Optional primary name, will be set to PrimaryTitle if not supplied

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PrimaryTitle
Title of the primary part of the link

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
