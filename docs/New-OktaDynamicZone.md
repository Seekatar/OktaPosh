---
external help file: OktaPosh-help.xml
Module Name: OktaPosh
online version: https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
schema: 2.0.0
---

# New-OktaDynamicZone

## SYNOPSIS
Create a new dynamic policy for blocklist zone

## SYNTAX

```
New-OktaDynamicZone [-Name] <String> [[-Locations] <Hashtable[]>] [[-ASNs] <String[]>] [[-ProxyType] <String>]
 [[-Usage] <String>] [-Inactive] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

## EXAMPLES

## PARAMETERS

### -ASNs
Array of string representation of an ASN numeric value

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
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

### -Inactive
Set to add as inactive

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

### -Locations
Array of hashtables like  @{ "country": "AX", "region": null }.
Region is optional.
See links section.

```yaml
Type: Hashtable[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
Name of the new zone.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProxyType
Type of proxy, Any, AnyProxy, Tor, NotTorAnonymizer.
Defaults to Any

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: Any, AnyProxy, Tor, NotTorAnonymizer

Required: False
Position: 3
Default value: Any
Accept pipeline input: False
Accept wildcard characters: False
```

### -Usage
BLOCKLIST or POLICY, defaults to POLICY

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: BLOCKLIST, POLICY

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS

[Country codes](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2)
[Region codes](https://en.wikipedia.org/wiki/ISO_3166-2)
[ASN Lookup](https://www.ultratools.com/tools/asnInfoResult)