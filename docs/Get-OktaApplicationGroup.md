---
external help file: OktaPosh-help.xml
Module Name: OktaPosh
online version:
schema: 2.0.0
---

# Get-OktaApplicationGroup

## SYNOPSIS
Get the list of groups attached to the application, or a specific group

## SYNTAX

### Query (Default)
```
Get-OktaApplicationGroup -AppId <String> [-Limit <UInt32>] [-Json] [<CommonParameters>]
```

### ById
```
Get-OktaApplicationGroup -AppId <String> -GroupId <String> [-Json] [<CommonParameters>]
```

### Next
```
Get-OktaApplicationGroup -AppId <String> [-Next] [-Json] [-NoWarn][<CommonParameters>]
```

## DESCRIPTION

## EXAMPLES

### Example 1
```
Get-OktaApplicationGroup -AppId $appId -Limit 5
Get-OktaApplicationGroup -Next
```

Get the first and second pages of an application's groups

## PARAMETERS

### -AppId
ApplicationId retrieved from Get-OktaApplication

```yaml
Type: String
Parameter Sets: (All)
Aliases: ApplicationId

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -GroupId
GroupId retrieved from Get-OktaGroup

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
Group objects

## NOTES

## RELATED LINKS
