---
external help file: OktaPosh-help.xml
Module Name: OktaPosh
online version:
schema: 2.0.0
---

# ConvertTo-OktaTrustedOriginYaml

## SYNOPSIS
Get Trusted Origin objects as Yaml for easy comparison between Okta instances.
Note that ConvertTo-OktaYaml calls this.

## SYNTAX

### Like
```
ConvertTo-OktaTrustedOriginYaml [[-OriginLike] <String>] [<CommonParameters>]
```

### Match
```
ConvertTo-OktaTrustedOriginYaml -OriginMatch <String> [<CommonParameters>]
```

## DESCRIPTION

## EXAMPLES

### Example 1
```powershell
ConvertTo-OktaTrustedOriginYaml -OriginLike '*cas*'
```

Get all the origins having cas in the origin

## PARAMETERS

### -OriginLike
Get origins urls like this pattern, defaults to '*'

```yaml
Type: String
Parameter Sets: Like
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OriginMatch
Get origins urls that match this regex pattern

```yaml
Type: String
Parameter Sets: Match
Aliases:

Required: True
Position: Named
Default value: None
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
