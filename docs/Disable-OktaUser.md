---
external help file: OktaPosh-help.xml
Module Name: OktaPosh
online version:
schema: 2.0.0
---

# Disable-OktaUser

## SYNOPSIS
Disables (deactivates) a user

## SYNTAX

```
Disable-OktaUser [-UserId] <String> [-SendEmail] [-Async] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

The user must not be in the DEPROVISIONED state

## EXAMPLES

### Example 1
```powershell
Disable-OktaUser -id 00u1etuu0flPrnIMK4x7
```

Disable a user

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

### -SendEmail
Set to send an email for activation.
Otherwise details are output.

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

### -UserId
UserId retrieved from Get-OktaUser

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
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Async
Process the disable asynchronously

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

### System.String

## OUTPUTS

### System.Object

## NOTES
Deactivating a user is a destructive operation.
The user is deprovisioned from all assigned applications which may destroy their data such as email or files.
This action cannot be recovered!

## RELATED LINKS
