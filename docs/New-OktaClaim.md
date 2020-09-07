---
external help file: OktaPosh-help.xml
Module Name: OktaPosh
online version:
schema: 2.0.0
---

# New-OktaClaim

## SYNOPSIS
Create a new Okta Claim

## SYNTAX

```
New-OktaClaim [-AuthorizationServerId] <String> [-Name] <String> [-ValueType] <String> [[-ClaimType] <String>]
 [-Value] <String> [-Inactive] [[-Scopes] <String[]>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## EXAMPLES

### EXAMPLE 1
```
PS C:\> New-OktaClaim -AuthorizationServerId ausoqi2fqgcUpYHBS4x6 -Name appName -ValueType EXPRESSION -ClaimType RESOURCE -Value app.profile.appName
```

### EXAMPLE 2
```
PS C:\> New-OktaClaim -AuthorizationServerId ausoqi2fqgcUpYHBS4x6 -Name test -ValueType EXPRESSION -ClaimType RESOURCE -Value app.profile.appName  -Verbose -Scopes "access_token"
```

## PARAMETERS
<!-- #include "./params/authServerId.md" -->

### -Name
Name for new Claim

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ValueType
Description

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ClaimType
RESOURCE (Access token) or IDENTITY (Identity Token)

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Value
Value to set

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 5
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

<!-- #include "./params/inactive.md" -->

### -Scopes
List of scopes to add to new Claim

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

<!-- #include "./params/whatif-confirm.md" -->
<!-- #include "./params/common-parameters.md" -->

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
