---
external help file: OktaPosh-help.xml
Module Name: OktaPosh
online version:
schema: 2.0.0
---

# Get-OktaGroup

## SYNOPSIS
Get one or more Okta Groups

## SYNTAX

### Query (Default)
```
Get-OktaGroup [-Query <String>] [-Limit <UInt32>] [-After <String>] [<CommonParameters>]
```

### ById
```
Get-OktaGroup -GroupId <String> [<CommonParameters>]
```

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-OktaGroup -GroupId 123
```

Get a group with id 123

## PARAMETERS

### -GroupId
GroupId from Okta. Can use query version to get it.

```yaml
Type: String
Parameter Sets: ById
Aliases: id

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Query
Query for name and description

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


### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).



## INPUTS

### System.String

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS

