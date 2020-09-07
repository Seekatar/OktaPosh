---
external help file: OktaPosh-help.xml
Module Name: OktaPosh
online version:
schema: 2.0.0
---

# Get-OktaRule

## SYNOPSIS
Get one or more rules for an auth server and policy

## SYNTAX

```
Get-OktaRule [-AuthorizationServerId] <String> [-PolicyId] <String> [[-Query] <String>] [<CommonParameters>]
```


## EXAMPLES

### Example 1
```
PS C:\>
```

## PARAMETERS

<!-- #include "./params/authServerId.md" -->


### -PolicyId
Id of a Policy.  Can be retrieved with Get-OktaPolicy

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

<!-- #include "./params/query.md" -->


<!-- #include "./params/common-parameters.md" -->

## INPUTS

### None
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
