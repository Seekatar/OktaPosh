---
external help file: OktaPosh-help.xml
Module Name: OktaPosh
online version:
schema: 2.0.0
---

# Set-OktaApplication

## SYNOPSIS
Update an Application

## SYNTAX

```
Set-OktaApplication [-Application] <PSObject> [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

## EXAMPLES

### Example 1
```
$spaApp = Get-OktaApplication -Id 123
$spaApp.label = "test-updated"
$result = Set-OktaApplication -Application $spaApp
```

Change an app's label

### Example 2
```
$spaApp = Get-OktaApplication -Id 123
$spaApp.settings.oauthClient.post_logout_redirect_uris += "http://localhost:8008/fp-ui/implicit/callback/fp-ui/"
$result = Set-OktaApplication -Application $spaApp
```

Add the the list of logout uris

## PARAMETERS

### -Application
Application object returned from Get-OktaApplication

```yaml
Type: PSObject
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
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
Application object

## NOTES

## RELATED LINKS
