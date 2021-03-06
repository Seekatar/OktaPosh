---
external help file: OktaPosh-help.xml
Module Name: OktaPosh
online version:
schema: 2.0.0
---

# Remove-OktaApplicationSchemaProperty

## SYNOPSIS
Remove a Property from a Schema.

## SYNTAX

```
Remove-OktaApplicationSchemaProperty [-AppId] <String> [-Name] <String> [-Json] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION

## EXAMPLES

### Example 1
```
Remove-OktaApplicationSchemaProperty -AppId $app.id -Name oktaPosh
```

Remove the oktaPosh property

## PARAMETERS

### -AppId
ApplicationId retrieved from Get-OktaApplication

```yaml
Type: String
Parameter Sets: (All)
Aliases: Id

Required: True
Position: 0
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
Name of the item

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

## OUTPUTS

## NOTES

## RELATED LINKS

[Set-OktaApplicationSchemaProperty](Set-OktaApplicationSchemaProperty.md)
