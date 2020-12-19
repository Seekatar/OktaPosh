---
external help file: OktaPosh-help.xml
Module Name: OktaPosh
online version:
schema: 2.0.0
---

# New-OktaRule

## SYNOPSIS
Create a new Rule on the AuthorizationServer's Policy

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
PS C:\> New-OktaRule -AuthorizationServerId $myapp.id -Name "Allow DRE" -PolicyId $drePolicy.id -Priority 1 -GrantTypes client_credentials -Scopes get_item,access_token,save_item
```

## PARAMETERS

### -AccessTokenLifetimeMinutes
How long the access token is valid

```yaml
Type: UInt32
Parameter Sets: (All)
Aliases:

Required: False
Position: 8
Default value: 60
Accept pipeline input: False
Accept wildcard characters: False
```

### -AuthorizationServerId
AuthorizationServerId retrieved from Get-OktaAuthorizationServer

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

### -GrantTypes
Types of grant for the Rule

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:
Accepted values: authorization_code, password, refresh_token, client_credentials, implicit

Required: True
Position: 4
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
Position: 7
Default value: EVERYONE
Accept pipeline input: False
Accept wildcard characters: False
```

### -Inactive
Set to add as inactive

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

### -Name
Name

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

### -PolicyId
Id of Policy to add to the rule from Get-OktaPolicy

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Priority
Rule Priority

```yaml
Type: UInt32
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: 1
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
Position: 9
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
Position: 10
Default value: 7
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
Position: 5
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
Position: 6
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

## OUTPUTS

### PSCustomObject

Rule object

## NOTES

## RELATED LINKS
