---
external help file: OktaPosh-help.xml
Module Name: OktaPosh
online version:
schema: 2.0.0
---

# Get-OktaTrustedOrigin

## SYNOPSIS
Get one or more TrustedOrigins

## SYNTAX

### Query (Default)
```
Get-OktaTrustedOrigin [-Filter <String>] [-Limit <UInt32>] [-Json] [<CommonParameters>]
```

### ById
```
Get-OktaTrustedOrigin -TrustedOriginId <String> [-Json] [<CommonParameters>]
```

### Next
```
Get-OktaTrustedOrigin [-Next] [-Json] [<CommonParameters>]
```

## DESCRIPTION
{{ Fill in the Description }}

## EXAMPLES

### Example 1
```
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Filter
Expression for filtering on properties.  See https://developer.okta.com/docs/reference/api-overview/#filtering

```yaml
Type: String
Parameter Sets: Query
Aliases:

Required: False
Position: Named
Default value: None
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

### -Limit
Specifies the number of results to return

```yaml
Type: UInt32
Parameter Sets: Query
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TrustedOriginId
Id of a TrustedOrigin

```yaml
Type: String
Parameter Sets: ById
Aliases: Id

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Next
Set to get the next page from a previous call (if one exists)

```yaml
Type: SwitchParameter
Parameter Sets: Next
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

## RELATED LINKS

