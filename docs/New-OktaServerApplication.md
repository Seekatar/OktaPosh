---
external help file: OktaPosh-help.xml
Module Name: OktaPosh
online version: https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
schema: 2.0.0
---

# New-OktaServerApplication

## SYNOPSIS
Create a new server-type OAuth Application

## SYNTAX

```
New-OktaServerApplication [-Label] <String> [-Inactive] [[-SignOnMode] <String>] [[-Properties] <Hashtable>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Long description

## EXAMPLES

### EXAMPLE 1
```
PS C:\> $app = New-OktaServerApplication -Label MyApp -Properties @{appName = "MyApp" }
```

Create a server with an appName property

## PARAMETERS

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

### -Inactive
Set to add as inactive

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

### -Label
Friendly name for the application

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

### -Properties
Additional properties to use in app.profile.\<name\> claims for the app

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SignOnMode
Defaults to OPENID_CONNECT

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: OPENID_CONNECT
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

### PSCustomObject
Application Object

## NOTES

## RELATED LINKS
