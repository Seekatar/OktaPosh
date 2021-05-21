---
external help file: OktaPosh-help.xml
Module Name: OktaPosh
online version:
schema: 2.0.0
---

# Get-OktaGroupUser

## SYNOPSIS
Get the Users attached to the Group

## SYNTAX

### Other (Default)
```
Get-OktaGroupUser [-GroupId <String>] [-Json] [<CommonParameters>]
```

### Limit
```
Get-OktaGroupUser [-GroupId <String>] [-Limit <UInt32>] [-Json] [<CommonParameters>]
```

### Next
```
Get-OktaGroupUser [-GroupId <String>] [-Next] [-Json] [-NoWarn][<CommonParameters>]
```

## DESCRIPTION

## EXAMPLES

## PARAMETERS

### -GroupId
GroupId retrieved from Get-OktaGroup

```yaml
Type: String
Parameter Sets: (All)
Aliases: Id

Required: False
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
Specifies the number of results to return

```yaml
Type: UInt32
Parameter Sets: Limit
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
