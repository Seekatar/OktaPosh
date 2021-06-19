---
external help file: OktaPosh-help.xml
Module Name: OktaPosh
online version:
schema: 2.0.0
---

# Get-OktaLog

## SYNOPSIS
Get Okta system log entries.
Defaults to getting 50 within last 10 minutes

## DESCRIPTION
By default this returns text output with local time, severity, actor, displayMessage, result, reason, and uuid. If you want to get the raw log to get more data, use -JSON or -Object.

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

Get log filtered by one id as an object. This is useful to get details about one record.

## PARAMETERS

### -Filter
Filter for event logs. 'event_type eq "user.session.start"'

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
Set to return JSON instead of text.

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
Limit the number of values returned, defaults to 50

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
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Objects
Set to return JSON instead of text

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

### -Query
Query for searching in the log

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
Add severity to the filter

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
Get records since a time.
Format it \d+(h|m|s) for recent hours, minutes or seconds.
Defaults to 10m

```yaml
Type: String
Parameter Sets: Query
Aliases:

Required: False
Position: Named
Default value: 10m
Accept pipeline input: False
Accept wildcard characters: False
```

### -SortOrder
DESCENDING or ASCENDING, defaults to ASCENDING

```yaml
Type: String
Parameter Sets: Query
Aliases:
Accepted values: DESCENDING, ASCENDING

Required: False
Position: Named
Default value: ASCENDING
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
