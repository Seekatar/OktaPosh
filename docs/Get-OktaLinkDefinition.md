---
external help file: OktaPosh-help.xml
Module Name: OktaPosh
online version:
schema: 2.0.0
---

# Get-OktaLinkDefinition

## SYNOPSIS
Get one or all a user-to-user link definitions

## SYNTAX

```
Get-OktaLinkDefinition [[-PrimaryName] <String>] [-Json] [<CommonParameters>]
```

## DESCRIPTION

## EXAMPLES

### Example 1
(Get-OktaLinkDefinition).primary.name | Remove-OktaLinkDefinition

Get all the link definitions and remove them

## PARAMETERS

### -Json
Set to return JSON instead of PSCustomObject

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

### -PrimaryName
The case sensitive primary name of the link definition. Leave empty for all link definitions.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
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
