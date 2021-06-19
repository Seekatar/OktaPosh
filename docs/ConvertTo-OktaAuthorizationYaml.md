---
external help file: OktaPosh-help.xml
Module Name: OktaPosh
online version:
schema: 2.0.0
---

# ConvertTo-OktaAuthorizationYaml

## SYNOPSIS
Get Authorization Server objects as Yaml for easy comparison between Okta instances.
Note that ConvertTo-OktaYaml calls this.

## SYNTAX

```
ConvertTo-OktaAuthorizationYaml [-OutputFolder] <String> [<CommonParameters>]
```

## DESCRIPTION
Get all the authorization server settings as yaml

## EXAMPLES

### Example 1
```powershell
$auth = Get-OktaAuthorizationServer -q test
$auth | ForEach-Object { Export-OktaAuthorizationServer -AuthorizationServerId $_.id -OutputFolder "$OutputFolder\$($_.name)" }

Get-ChildItem $OutputFolder -Directory | ForEach-Object { ConvertTo-OktaAuthorizationYaml $_ | Out-File (Join-Path $_ auth.yaml) }
```

Export test auth servers then get the yaml for each.
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
