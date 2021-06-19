---
external help file: OktaPosh-help.xml
Module Name: OktaPosh
online version:
schema: 2.0.0
---

# ConvertTo-OktaYaml

## SYNOPSIS
Get auth, app, trusted origin, and group objects as Yaml for easy comparison between Okta instances

## SYNTAX

```
ConvertTo-OktaYaml [-OutputFolder] <String> [[-AuthServerQuery] <String>] [[-ApplicationQuery] <String>]
 [[-OriginLike] <String>] [-GroupQueries <String[]>] [-WipeFolder] [<CommonParameters>]
```

## DESCRIPTION

## EXAMPLES

### Example 1
```powershell
ConvertTo-OktaYaml -OutputFolder c:\temp\okta -AuthServerQuery test -ApplicationQuery test -OriginLike * -GroupQueries abc,test -WipeFolder
```

Get all test apps and auth servers,  all origins, and groups matching abc or test

## PARAMETERS

### -ApplicationQuery
Searches the name or label property of applications

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AuthServerQuery
Searches the name and audiences of Authorization Servers for matching values

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OutputFolder
Folder for the output.
It will be created if it doesn't exist

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

### -OriginLike
Get origins urls like this pattern, defaults to '*'

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WipeFolder
Set to delete everything in the Output folder

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

### -GroupQueries
Array of query strings for getting groups

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
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
