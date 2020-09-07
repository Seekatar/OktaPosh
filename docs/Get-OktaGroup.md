---
external help file: OktaPosh-help.xml
Module Name: OktaPosh
online version:
schema: 2.0.0
---

# Get-OktaGroup

## SYNOPSIS
Get one or more Okta Groups

## SYNTAX

### Query (Default)
```
Get-OktaGroup [-Query <String>] [-Limit <UInt32>] [-After <String>] [<CommonParameters>]
```

### ById
```
Get-OktaGroup -GroupId <String> [<CommonParameters>]
```

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-OktaGroup -GroupId 123
```

Get a group with id 123

## PARAMETERS

### -GroupId
GroupId from Okta. Can use query version to get it.

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

<!-- #include "./params/query.md" -->
<!-- #include "./params/limit.md" -->
<!-- #include "./params/after.md" -->

<!-- #include "./params/common-parameters.md" -->


## INPUTS

### System.String

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
