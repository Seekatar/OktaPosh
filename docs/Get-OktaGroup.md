---
external help file: OktaPosh-help.xml
Module Name: OktaPosh
online version:
schema: 2.0.0
---

# Get-OktaGroup

## SYNOPSIS
Get one or more Groups

## SYNTAX

### Query (Default)
```
Get-OktaGroup [-Query <String>] [-Filter <String>] [-Search <String>] [-Limit <UInt32>] [-Json]
 [<CommonParameters>]
```

### ById
```
Get-OktaGroup -GroupId <String> [-Json] [<CommonParameters>]
```

### Next
```
Get-OktaGroup [-Next] [-Json] [-NoWarn][<CommonParameters>]
```

## DESCRIPTION

## EXAMPLES

### Example 1
```
PS C:\> Get-OktaGroup -GroupId 123
```

Get a group with id 123

### Example 2
```
Get-OktaGroup -Search 'profile.name eq "MyGroupName"'
```

Get a group with MyGroupName

## PARAMETERS

### -Filter
Expression for filtering on properties. See https://developer.okta.com/docs/reference/api-overview/#Filter

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

### -GroupId
GroupId from Okta.
Can use query version to get it.

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
Parameter Sets: Query
Aliases:

Required: False
Position: Named
Default value: 0
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
Searches in the name property

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

### -Search
Searches for groups with a supported filtering expression for all attributes except for _embedded, _links, and objectClass. See https://developer.okta.com/docs/reference/api/groups/#list-groups-with-search

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

### -NoWarn
For -Next when no results, do not show warning

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

### String
Pipe Ids in

### PSCustomObject[]
Pipe objects with Id

## OUTPUTS

### PSCustomObject[]
Group Objects

## NOTES

## RELATED LINKS
