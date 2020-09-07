---
external help file: OktaPosh-help.xml
Module Name: OktaPosh
online version:
schema: 2.0.0
---

# Get-OktaPolicy

## SYNOPSIS
Get one of more Policies for an AuthorizationServer's rule

## SYNTAX

### ById
```
Get-OktaPolicy -AuthorizationServerId <String> -RuleId <String> [<CommonParameters>]
```

### Query
```
Get-OktaPolicy -AuthorizationServerId <String> [-Query <String>] [<CommonParameters>]
```


## EXAMPLES

### Example 1
```
PS C:\>
```

## PARAMETERS

<!-- #include "./params/authServerId.md" -->

<!-- #include "./params/query.md" -->

### -RuleId
Id of a Rule

```yaml
Type: String
Parameter Sets: ById
Aliases: id

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

<!-- #include "./params/common-parameters.md" -->

## INPUTS

### System.String
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
