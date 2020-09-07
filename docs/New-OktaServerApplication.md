---
external help file: OktaPosh-help.xml
Module Name: OktaPosh
online version:
schema: 2.0.0
---

# New-OktaServerApplication

## SYNOPSIS
Create a new server-type OAuth Application

## SYNTAX

```
New-OktaServerApplication [-Label] <String> [-Inactive] [[-SignOnMode] <String>] [[-Properties] <Hashtable>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Long description

## EXAMPLES

### EXAMPLE 1
```
PS C:\> $app = New-OktaServerApplication -Label MyApp -Properties @{appName = "MyApp" }
```

Create a server with an appName property

## PARAMETERS

### -Label
Friendly name for the application

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

<!-- #include "./params/inactive.md" -->

### -SignOnMode
Defaults to OPENID_CONNECT

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: OPENID_CONNECT
Accept pipeline input: False
Accept wildcard characters: False
```

### -Properties
Additional properties to use in app.profile.\<name\> claims for the app

```yaml
Type: Hashtable
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

## OUTPUTS

## NOTES

## RELATED LINKS
