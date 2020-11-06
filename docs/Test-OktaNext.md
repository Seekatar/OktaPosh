---
external help file: OktaPosh-help.xml
Module Name: OktaPosh
online version:
schema: 2.0.0
---

# Test-OktaNext

## SYNOPSIS
Checks to see if -Next will return anything for a give Okta object

## SYNTAX

```
Test-OktaNext [[-ObjectName] <String>]
```

## DESCRIPTION

## EXAMPLES

### Example 1
```powershell
Test-OktaNext users
```

Checks to see if Get-OktaUser -Next will return anything without making a call.

## PARAMETERS

### -ObjectName
Base-level object name. Use tab completion for valid values

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: groups, users, apps, authorizationServers

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

### None

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
