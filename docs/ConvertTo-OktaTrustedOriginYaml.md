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

```
ConvertTo-OktaTrustedOriginYaml [[-OriginLike] <String>] [<CommonParameters>]
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
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
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
