---
external help file: OktaPosh-help.xml
Module Name: OktaPosh
online version:
schema: 2.0.0
---

# Get-OktaLog

## SYNOPSIS
Get Okta system log entries. Defaults to getting 50 within last 10 minutes

## SYNTAX

### Query (Default)
```
Get-OktaLog [-Query <String>] [-Since <String>] [-SortOrder <String>] [-Filter <String>] [-Limit <Int32>]
 [-Severity <String>] [-Json] [-Objects] [<CommonParameters>]
```

### Next
```
Get-OktaLog [-Json] [-Objects] [-Next] [-NoWarn] [<CommonParameters>]
```

## EXAMPLES

### Example 1
```powershell
Get-OktaLog 
```

Get most recent 10 minutes of logs

### Example 2
```powershell
Get-OktaLog -since 10m  -Severity ERROR
Get-OktaLog -Next
Get-OktaLog -Next
```

Get log that are errors, then get next twice

### Example 3
```powershell
Get-OktaLog -filter 'uuid eq "ccac98c4-d026-11eb-8ea5-a5b75f62156a"' -object 
```

Get log filtered by one id as an object

## PARAMETERS

### -Filter
{{ Fill Filter Description }}

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
{{ Fill Json Description }}

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
{{ Fill Limit Description }}

```yaml
Type: Int32
Parameter Sets: Query
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Next
{{ Fill Next Description }}

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

### -NoWarn
{{ Fill NoWarn Description }}

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

### -Objects
{{ Fill Objects Description }}

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

### -Query
{{ Fill Query Description }}

```yaml
Type: String
Parameter Sets: Query
Aliases: Q

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Severity
{{ Fill Severity Description }}

```yaml
Type: String
Parameter Sets: Query
Aliases:
Accepted values: DEBUG, INFO, WARN, ERROR

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Since
{{ Fill Since Description }}

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

### -SortOrder
{{ Fill SortOrder Description }}

```yaml
Type: String
Parameter Sets: Query
Aliases:
Accepted values: DESCENDING, ASCENDING

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
