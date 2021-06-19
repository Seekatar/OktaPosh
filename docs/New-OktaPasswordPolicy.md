---
external help file: OktaPosh-help.xml
Module Name: OktaPosh
online version:
schema: 2.0.0
---

# New-OktaPasswordPolicy

## SYNOPSIS
Create a new Okta password policy

## SYNTAX

```
New-OktaPasswordPolicy [-Name] <String> [[-Description] <String>] [-Inactive] [[-Priority] <Int32>]
 [[-MinLength] <Int32>] [[-MinLowerCase] <Int32>] [[-MinUpperCase] <Int32>] [[-MinNumber] <Int32>]
 [[-MinSymbol] <Int32>] [[-MaxAgeDays] <Int32>] [[-ExpireWarnDays] <Int32>] [[-MinAgeMinutes] <Int32>]
 [[-HistoryCount] <Int32>] [[-MaxAttempts] <Int32>] [[-AutoUnlockMinutes] <Int32>] [-ExcludeUserName]
 [-ExcludeDictionaryCommon] [[-ExcludeAttributes] <String[]>] [[-IncludeGroups] <String[]>]
 [[-RecoveryQuestionStatus] <String>] [[-Provider] <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
This will create a new Okta password policy given the various values passed in

## EXAMPLES

### Example 1
```powershell
$groups = (Get-OktaGroup -q GroupNamePrefix)
$parms = @{
    Name = $name
    Description = $name
    Priority = 4
    RecoveryQuestionStatus = "INACTIVE"
    IncludeGroups = ($groups.id)
}
$policy = New-OktaPasswordPolicy @parms -verbose
```

Create a new policy with a bunch of groups matching a pattern

## PARAMETERS

### -AutoUnlockMinutes
AutoUnlockMinutes defaults to 5

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 13
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Description
Description for the policy.
Defaults to "Added by OktaPosh"

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExcludeAttributes
Array of attributes to exclude from password

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 14
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExcludeDictionaryCommon
Set to exclude common dictionary words

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

### -ExcludeUserName
Set to exclude username

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

### -ExpireWarnDays
ExpireWarnDays defaults to 0

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 9
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -HistoryCount
HistoryCount defaults to 5

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 11
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Inactive
Set to create as INACTIVE

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

### -IncludeGroups
Groups to include in the policy

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 15
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MaxAgeDays
MaxAgeDays defaults to 60

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 8
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MaxAttempts
MaxAttempts defaults to 3

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 12
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MinAgeMinutes
MinAgeMinutes defaults to 0

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 10
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MinLength
MinLength defaults to 8

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MinLowerCase
MinLowerCase defaults to 1

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MinNumber
MinNumber defaults to 1

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MinSymbol
MinSymbol defaults to 0

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MinUpperCase
MinUpperCase defaults to 1

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
Name of the policy.
Must be unique

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Priority
Priority of the policy.
This will likely be adjusted by Okta.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Provider
Provider defaults to OKTA

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: OKTA, Active Directory

Required: False
Position: 17
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RecoveryQuestionStatus
RecoveryQuestionStatus.
For some systems this cannot be set to INACTIVE

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: ACTIVE, INACTIVE

Required: False
Position: 16
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: False
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
