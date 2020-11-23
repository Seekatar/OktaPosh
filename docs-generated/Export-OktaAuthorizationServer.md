---
external help file: OktaPosh-help.xml
Module Name: OktaPosh
online version:
schema: 2.0.0
---

# Export-OktaAuthorizationServer

## SYNOPSIS
Export the AuthorizationServer and its Claims, Scopes, Policies and their Rules

## SYNTAX

```
Export-OktaAuthorizationServer [-AuthorizationServerId] <String> [-OutputFolder] <String> [<CommonParameters>]
```

## DESCRIPTION
This can be used for comparing configuration between AuthorizationServers or Okta instances.

## EXAMPLES

### Example 1
```
mkdir "\temp\authserver_$($authserver.id)"
Export-OktaAuthorizationServer  $authServer.id
```

Export an Authorization server to a folder.

## PARAMETERS

### -AuthorizationServerId
AuthServerId retrieved from Get-OktaAuthorizationServer

```yaml
Type: String
Parameter Sets: (All)
Aliases: Id

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -OutputFolder
Existing folder to save the JSON output to

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None
## OUTPUTS

### List of fully qualified path names.
## NOTES

## RELATED LINKS

