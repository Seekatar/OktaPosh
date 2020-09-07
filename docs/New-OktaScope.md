---
external help file: OktaPosh-help.xml
Module Name: OktaPosh
online version:
schema: 2.0.0
---

# New-OktaScope

## SYNOPSIS
Add an Okta Authorization Scope

## SYNTAX

```
New-OktaScope [-AuthorizationServerId] <String> [-Name] <String> [[-Description] <String>] [-MetadataPublish]
 [-DefaultScope] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## EXAMPLES

### EXAMPLE 1
```
PS C:\> "access_token","get_item","save_item","remove_item" | New-OktaScope -AuthorizationServerId ausoqi2fqgcUpYHBS4x6 -Description "Added via script"
```

Add four scopes

## PARAMETERS
<!-- #include "./params/authServerId.md" -->

### -Name
Name of the new Scope

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

<!-- #include "./params/description.md" -->
### -MetadataPublish
Set to publish in meta data

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

### -DefaultScope
Set to include in the default scope

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

<!-- #include "./params/whatif-confirm.md" -->

<!-- #include "./params/common-parameters.md" -->


## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
