---
external help file: OktaPosh-help.xml
Module Name: OktaPosh
online version:
schema: 2.0.0
---

# Get-OktaApplication

## SYNOPSIS
Get one or more Okta Applications

## SYNTAX

### Query (Default)
```
Get-OktaApplication [-Query <String>] [-Limit <UInt32>] [-After <String>] [<CommonParameters>]
```

### ById
```
Get-OktaApplication -AppId <String> [<CommonParameters>]
```

## DESCRIPTION

## EXAMPLES

### EXAMPLE 1
```
PS C:\> Get-OktaApplication -Query "MyApp"
```

Get applications with MyApp in the name or description

## PARAMETERS

### -AppId
Application id to get.

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

## OUTPUTS

## NOTES

## RELATED LINKS
