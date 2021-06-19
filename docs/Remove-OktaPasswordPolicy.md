---
external help file: OktaPosh-help.xml
Module Name: OktaPosh
online version:
schema: 2.0.0
---

# Remove-OktaPasswordPolicy

## SYNOPSIS
Delete a password policy

## SYNTAX

```
Remove-OktaPasswordPolicy [-PolicyId] <String> [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
PolicyId retrieved from Get-OktaPasswordPolicy

## EXAMPLES

### Example 1
```powershell
Get-OktaPolicy -Type PASSWORD | ? system -eq $false | Remove-OktaPolicy
```

Remove all non-system policies

## PARAMETERS

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

### -PolicyId
{{ Fill PolicyId Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases: Id

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
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

### System.String

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
