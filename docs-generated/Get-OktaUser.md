---
external help file: OktaPosh-help.xml
Module Name: OktaPosh
online version:
schema: 2.0.0
---

# Get-OktaUser

## SYNOPSIS
Get one or more Okta Users

## SYNTAX

### Query (Default)
```
Get-OktaUser [-Query <String>] [-Filter <String>] [-Limit <UInt32>] [-After <String>] [-Json]
 [<CommonParameters>]
```

### ById
```
Get-OktaUser -UserId <String> [-Json] [<CommonParameters>]
```

### Search
```
Get-OktaUser [-Query <String>] [-Filter <String>] [-Limit <UInt32>] [-After <String>] [-Search <String>]
 [-SortBy <String>] [-SortOrder <String>] [-Json] [<CommonParameters>]
```

## DESCRIPTION

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -After
Value returned from previous call to Get for continuing

```yaml
Type: String
Parameter Sets: Query, Search
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Filter
Expression for filtering on properties

```yaml
Type: String
Parameter Sets: Query, Search
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
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Limit
Limit the number of values returned

```yaml
Type: UInt32
Parameter Sets: Query, Search
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Query
Searches by first name, last name and email

```yaml
Type: String
Parameter Sets: Query, Search
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Search
Searches for users with a supported filtering expression for most properties

```yaml
Type: String
Parameter Sets: Search
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SortBy
Specifies field to sort by (for search queries only)

```yaml
Type: String
Parameter Sets: Search
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SortOrder
Specifies sort order asc or desc (for search queries only)

```yaml
Type: String
Parameter Sets: Search
Aliases:
Accepted values: asc, desc

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UserId
The id of the user

```yaml
Type: String
Parameter Sets: ById
Aliases: Login, Id

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
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

