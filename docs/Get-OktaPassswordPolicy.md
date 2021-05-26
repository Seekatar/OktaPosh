---
external help file: OktaPosh-help.xml
Module Name: OktaPosh
online version:
schema: 2.0.0
---

# Get-OktaPassswordPolicy

## SYNOPSIS
PolicyId retrieved from Get-OktaPasswordPolicy

## SYNTAX

### ById (Default)
```
Get-OktaPassswordPolicy [-PolicyId] <String> [-WithRules] [-JSON] [<CommonParameters>]
```

### ByType
```
Get-OktaPassswordPolicy -Type <String> [-JSON] [<CommonParameters>]
```

## DESCRIPTION
Get policies based on the type or id

## EXAMPLES

### Example 1
```powershell
$policies = Get-OktaPolicy -Type PASSWORD
```

Get password policies

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
PolicyId retrieved from Get-OktaPasswordPolicy

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
Type of policy to retrieve

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
Also return the rules. If there are more than 20 Okta will return an error.

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
