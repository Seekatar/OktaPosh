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
Get-OktaUser [-Query <String>] [-Filter <String>] [-Limit <UInt32>] [-Json] [<CommonParameters>]
```

### ById
```
Get-OktaUser -UserId <String> [-Json] [<CommonParameters>]
```

### Search
```
Get-OktaUser [-Query <String>] [-Filter <String>] [-Limit <UInt32>] [-Search <String>] [-SortBy <String>]
 [-SortOrder <String>] [-Json] [<CommonParameters>]
```

### Next
```
Get-OktaUser [-Next] [-Json] [<CommonParameters>]
```

## DESCRIPTION

## EXAMPLES

### Example 1
```
Get-Oktauser  -limit 1 -filter 'profile.firstName eq "jim"'
```

Get first user who has firstname of 'jim'

### Example 2
```
Get-Oktauser  -Login testuser@test.com
```

Get a user by login

### Example 3
```
Get-Oktauser -Id 000012224444555
```

Get a user by id

## PARAMETERS

### -Filter
Expression for filtering on properties.
See https://developer.okta.com/docs/reference/api/users/#list-users-with-a-filter

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
Default value: False
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

### -Next
Set to get the next page from a previous call (if one exists)

```yaml
Type: SwitchParameter
Parameter Sets: Next
Aliases:

Required: False
Position: Named
Default value: False
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
Searches for users with a supported filtering expression for most properties.
See https://developer.okta.com/docs/reference/api/users/#list-users-with-search

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
UserId retrieved from Get-OktaUser

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

### String
Pipe Ids in

### PSCustomObject[]
Pipe objects with Id

## OUTPUTS

### PSCustomObject[]
User Objects

## NOTES

## RELATED LINKS
