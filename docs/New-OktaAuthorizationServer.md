---
external help file: OktaPosh-help.xml
Module Name: OktaPosh
online version:
schema: 2.0.0
---

# New-OktaAuthorizationServer

## SYNOPSIS
Create a new AuthorizationServer

## SYNTAX

```
New-OktaAuthorizationServer [-Name] <String> [-Audience] <String> [-Issuer] <String> [[-Description] <String>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Long description

## EXAMPLES

### EXAMPLE 1
```
PS C:\> New-OktaAuthorizationServer -Name RelianceApi -Audience "http://cccis.com/reliance/api" -Issuer "http:/cccis.com/reliance"
```

## PARAMETERS

### -Name
Name of authorization server

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

### -Audience
Audience value

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

### -Issuer
Issuer value

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

<!-- #include "./params/description.md" -->

<!-- #include "./params/whatif-confirm.md" -->
<!-- #include "./params/common-parameters.md" -->

## INPUTS

## OUTPUTS

## NOTES
General notes

## RELATED LINKS
