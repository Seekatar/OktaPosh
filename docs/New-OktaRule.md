---
external help file: OktaPosh-help.xml
Module Name: OktaPosh
online version:
schema: 2.0.0
---

# New-OktaRule

## SYNOPSIS
Short description

## SYNTAX

```
New-OktaRule [-AuthorizationServerId] <String> [-PolicyId] <String> [-Name] <String> [-Inactive]
 [[-Priority] <UInt32>] [-GrantTypes] <String[]> [[-Scopes] <String[]>] [[-UserIds] <String[]>]
 [[-GroupIds] <String[]>] [[-AccessTokenLifetimeMinutes] <UInt32>] [[-RefreshTokenLifetimeMinutes] <UInt32>]
 [[-RefreshTokenWindowDays] <UInt32>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Long description

## EXAMPLES

### EXAMPLE 1
```
PS C:\> New-OktaRule -AuthorizationServerId $reliance.id -Name "Allow DRE" -PolicyId $drePolicy.id -Priority 1 -GrantTypes client_credentials -Scopes get_item,access_token,save_item
```

## PARAMETERS
<!-- #include "./params/authServerId.md" -->

### -PolicyId
Id of Policy to add to the rule from Get-OktaPolicy

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
Name

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

<!-- #include "./params/inactive.md" -->

### -Priority
Rule Priority

```yaml
Type: UInt32
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: 1
Accept pipeline input: False
Accept wildcard characters: False
```

### -GrantTypes
Type of grant for the Rule

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Scopes
Scopes to add to the Rule

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UserIds
UserIds to add to the Rule

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -GroupIds
GroupIds to add to the Rule

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 8
Default value: EVERYONE
Accept pipeline input: False
Accept wildcard characters: False
```

### -AccessTokenLifetimeMinutes
How long the access token is valid

```yaml
Type: UInt32
Parameter Sets: (All)
Aliases:

Required: False
Position: 9
Default value: 60
Accept pipeline input: False
Accept wildcard characters: False
```

### -RefreshTokenLifetimeMinutes
How long the refresh token is valid

```yaml
Type: UInt32
Parameter Sets: (All)
Aliases:

Required: False
Position: 10
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -RefreshTokenWindowDays
Parameter description

```yaml
Type: UInt32
Parameter Sets: (All)
Aliases:

Required: False
Position: 11
Default value: 7
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
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
General notes

## RELATED LINKS