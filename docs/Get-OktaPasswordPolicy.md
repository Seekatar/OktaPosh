---
external help file: OktaPosh-help.xml
Module Name: OktaPosh
online version:
schema: 2.0.0
---

# Get-OktaPasswordPolicy

## SYNOPSIS
Get a password policy

## SYNTAX

### ByType (Default)
```
Get-OktaPasswordPolicy [-Type <String>] [-JSON] [<CommonParameters>]
```

### ById
```
Get-OktaPasswordPolicy [-PolicyId] <String> [-WithRules] [-JSON] [<CommonParameters>]
```

## DESCRIPTION


## EXAMPLES

## PARAMETERS

### -JSON
Set to return JSON instead of PSCustomObject

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

### -PolicyId
The policy id retrieved from Get-OktaPolicy

```yaml
Type: String
Parameter Sets: ById
Aliases: Id

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Type
Type of policy to get.

```yaml
Type: String
Parameter Sets: ByType
Aliases:
Accepted values: OKTA_SIGN_ON, PASSWORD, MFA_ENROLL, OAUTH_AUTHORIZATION_POLICY, IDP_DISCOVERY, USER_LIFECYCLE

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WithRules
If set will also return the policy rules in _embedded

```yaml
Type: SwitchParameter
Parameter Sets: ById
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

### System.String

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
