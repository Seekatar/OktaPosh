---
external help file: OktaPosh-help.xml
Module Name: OktaPosh
online version:
schema: 2.0.0
---

# Get-OktaRule

## SYNOPSIS
Get one or more Rules for an AuthorizationServer and Policy

## SYNTAX

### Query (Default)
```
Get-OktaRule -AuthorizationServerId <String> -PolicyId <String> [-Query <String>] [-Json] [<CommonParameters>]
```

### ById
```
Get-OktaRule -AuthorizationServerId <String> -PolicyId <String> -RuleId <String> [-Json] [<CommonParameters>]
```

## DESCRIPTION

## EXAMPLES

## PARAMETERS

### -AuthorizationServerId
AuthorizationServerId retrieved from Get-OktaAuthorizationServer

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Json
Set to return JSON instead of PSCustomObject

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

### -PolicyId
PolicyId retrieved from Get-OktaPolicy

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Query
Query for name and description

```yaml
Type: String
Parameter Sets: Query
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RuleId
RuleId retrieved from Get-OktaRule

```yaml
Type: String
Parameter Sets: ById
Aliases: Id

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### String
Pipe Ids in

### PSCustomObject[]
Pipe objects with Id

## OUTPUTS

### PSCustomObject[]
Rule Objects

## NOTES

## RELATED LINKS
