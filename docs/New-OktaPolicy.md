---
external help file: OktaPosh-help.xml
Module Name: OktaPosh
online version:
schema: 2.0.0
---

# New-OktaPolicy

## SYNOPSIS
Create a new Policy on the AuthorizationServer

## SYNTAX

```
New-OktaPolicy [-AuthorizationServerId] <String> [-Name] <String> [[-Description] <String>] [-Inactive]
 [[-Priority] <UInt32>] [[-ClientIds] <String[]>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## EXAMPLES

### Example 1
```powershell
PS C:\>
```

## PARAMETERS
<!-- #include "./params/authServerId.md" -->

### -ClientIds
Array of client ids to add to this Policy

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
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

<!-- #include "./params/description.md" -->
<!-- #include "./params/inactive.md" -->

### -Name
Name of the policy

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
Numeric priority of policy

```yaml
Type: UInt32
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

<!-- #include "./params/whatif-confirm.md" -->
<!-- #include "./params/common-parameters.md" -->


## INPUTS

### None

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
