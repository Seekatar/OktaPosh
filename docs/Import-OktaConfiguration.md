---
external help file: OktaPosh-help.xml
Module Name: OktaPosh
online version:
schema: 2.0.0
---

# Import-OktaConfiguration

## SYNOPSIS
Import Okta Authorization servers, applications, groups and related objects

## SYNTAX

```
Import-OktaConfiguration [[-JsonConfig] <String>] [[-Variables] <Hashtable>] [-DumpConfig] [-Quiet] [-Force]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
This function takes a JSON file that declares Okta objects. It add authorization servers, scopes, policies, rules, which is required. It also adds groups, and will associated them with the auth server. And it adds SPA and server applications and associates them to the auth server and groups. See about_import for details.

## EXAMPLES

### EXAMPLE 1
```
Import-OktaConfiguration -JsonConfig C:\code\OktaPosh\OktaPosh\public\ui-app.json -DumpConfig -Variables @{ cluster = "nonprod"; domainSuffix = "dev" }
```

Dump out the config to check on variable replacements

### EXAMPLE 2
```
$variables = @{
    cluster = "nonprod"
    domainSuffix = "-dev"
    additionalRedirect = "http://localhost:8008/fp-ui/implicit/callback"
    groupNames = "groupNames.json"
    groupObjects = "groups.json"
}
Import-OktaConfiguration -JsonConfig C:\code\OktaPosh\tests\samples\import\ui-many-groups-app.json -Variables $variables
```

Import using two files to substitute in

### EXAMPLE 3
```
$variables = @{
    cluster = "nonprod"
    domainSuffix = "-dev"
    additionalRedirect = "http://localhost:8009/dc-ui/implicit/callback"
}
Import-OktaConfiguration -JsonConfig C:\code\OktaPosh\OktaPosh\public\ui-app.json -DumpConfig -Variables $variables
```

Dump out the config to check on variable replacements

### EXAMPLE 4
```
$variables = @{
    cluster = "nonprod"
    domainSuffix = "-dev"
    additionalRedirect = "http://localhost:8008/imageintake-ui/implicit/callback"
}
Import-OktaConfiguration -JsonConfig ui-and-app.json -Variables $variables
```

Import ui and server app for an application

## PARAMETERS

### -JsonConfig
The JSON file defining all the objects. See about_import for details

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: C:\code\OktaPosh\OktaPosh\public\datacapture-ui.json
Accept pipeline input: False
Accept wildcard characters: False
```

### -Variables
Optional variables to override in the JSON. Useful for deployments where some values may differ from one environment to another.

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: @{ cluster = "nonprod"; domainSuffix = "dev" }
Accept pipeline input: False
Accept wildcard characters: False
```

### -DumpConfig
Set to dump out the JSON after variable replacements. Highly recommended to test variable substitution.

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

### -Quiet
Set to suppress Write-Information messages.

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

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
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

### -Force
Import even if get warning about {{ in configuration

```yaml
Type: SwitchParameter
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

## OUTPUTS

## NOTES

## RELATED LINKS

[OktaPosh Readme](https://github.com/Seekatar/OktaPosh/blob/main/README.md)
