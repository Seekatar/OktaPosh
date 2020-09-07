---
external help file: OktaPosh-help.xml
Module Name: OktaPosh
online version:
schema: 2.0.0
---

# Set-OktaApplicationProperty

## SYNOPSIS
Set an application property

## SYNTAX

```
Set-OktaApplicationProperty [-Application] <PSObject> [-Properties] <Hashtable> [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
This will set a property on the application that can be used in a Claim with an Expression of app.profile.\<name\>

## EXAMPLES

### EXAMPLE 1
```
$app = Get-OktaApplcation $appId
Set-OktaApplicationProperty -Application $app -Properties @{client_id = "INS1", client_profile_id = 1234 }
```

Set client_id and client_profile_id on the app

## PARAMETERS

### -Application
Application returned from Get-OktaApplication

```yaml
Type: PSObject
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Properties
Hashtable of properties and the values to set on the Application

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
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
General notes

## RELATED LINKS

