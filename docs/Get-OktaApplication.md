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
Get-OktaApplication [-Query <String>] [-Limit <UInt32>] [-Json] [-IncludeOkta] [<CommonParameters>]
```

### ById
```
Get-OktaApplication -AppId <String> [-Json] [-IncludeOkta] [<CommonParameters>]
```

### Next
```
Get-OktaApplication [-Next] [-Json] [-NoWarn] [-IncludeOkta] [<CommonParameters>]
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

### -NoWarn
For -Next when no results, do not show warning

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

### -IncludeOkta
Set to also include apps that start with "Okta "

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### String
Pipe Ids in

### PSCustomObject[]
Pipe objects with Id

## OUTPUTS

### PSCustomObject[]
Application objects

## NOTES

## RELATED LINKS
