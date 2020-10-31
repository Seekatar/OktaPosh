---
external help file: OktaPosh-help.xml
Module Name: OktaPosh
online version:
schema: 2.0.0
---

# Set-OktaOption

## SYNOPSIS
Set OktaOptions for accessing the API

## SYNTAX

```
Set-OktaOption [[-ApiToken] <String>] [[-BaseUri] <String>] [<CommonParameters>]
```

## DESCRIPTION

## EXAMPLES

### EXAMPLE 1
```
PS Set-OktaOption -ApiToken abc123 -BaseUri https://devcccis.oktapreview.com/
```

## PARAMETERS

### -ApiToken
API token from Okta

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: $env:OKTA_API_TOKEN
Accept pipeline input: False
Accept wildcard characters: False
```

### -BaseUri
Base Okta URI for all API calls

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: $env:OKTA_BASE_URI
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
