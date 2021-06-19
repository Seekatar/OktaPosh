---
external help file: OktaPosh-help.xml
Module Name: OktaPosh
online version:
schema: 2.0.0
---

# ConvertTo-OktaApplicationYaml

## SYNOPSIS
Get Application objects as Yaml for easy comparison between Okta instances.
Note that ConvertTo-OktaYaml calls this.

## SYNTAX

```
ConvertTo-OktaApplicationYaml [[-Query] <String>] [-OutputFolder] <String> [<CommonParameters>]
```

## DESCRIPTION

## EXAMPLES

### Example 1
```powershell
ConvertTo-OktaApplicationYaml -q test -OutputFolder c:\temp\okta
```

Get yaml for test applications into c:\temp\okta.
Note that ConvertTo-OktaYaml calls this.

## PARAMETERS

### -OutputFolder
Folder for the output.
It will be created if it doesn't exist

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

### -Query
Searches the name or label property of applications

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
