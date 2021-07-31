---
external help file: OktaPosh-help.xml
Module Name: OktaPosh
online version:
schema: 2.0.0
---

# Reset-OktaPassword

## SYNOPSIS
Reset the password of a user

## SYNTAX

```
Reset-OktaPassword [-UserId] <String> [-SendEmail] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Generates a one-time token (OTT) that can be used to reset a user's password.
The link is returned, or emailed if -SendEmail is set

## EXAMPLES

### Example 1
```PowerShell
Get-OktaUser -Login testUser123 | Reset-OktaPassword
```

Resets testUser123's password and returns the link that you can use or send to the user

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
If true sends an email with a reset link, otherwise returns the reset password link

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
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

## OUTPUTS

### Password link if -SendEmail is not set

## NOTES

## RELATED LINKS
