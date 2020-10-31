---
external help file: OktaPosh-help.xml
Module Name: OktaPosh
online version:
schema: 2.0.0
---

# Get-OktaApplication

## SYNOPSIS
Get one or more Applications

## SYNTAX

### Query (Default)
```
Get-OktaApplication [-Query <String>] [-Limit <UInt32>] [-After <String>] [-Json] [<CommonParameters>]
```

### ById
```
Get-OktaApplication -AppId <String> [-Json] [<CommonParameters>]
```

## DESCRIPTION

## EXAMPLES

### EXAMPLE 1
```
PS C:\> Get-OktaApplication -Query "MyApp"
```

Get applications with MyApp in the name or description

## PARAMETERS

### -AppId
Application id to get.

```yaml
Type: String
Parameter Sets: ById
Aliases: ApplicationId, Id

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Query
Searches the name or label property of applications

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

### -Limit
Limit the number of values returned

```yaml
Type: UInt32
Parameter Sets: Query
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -After
Value returned from previous call to Get for continuing

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
