---
external help file: OktaPosh-help.xml
Module Name: OktaPosh
online version:
schema: 2.0.0
---

# Get-OktaAppJwt

## SYNOPSIS
Get the JWT for client_credential (server-to-server)

## SYNTAX

```
Get-OktaAppJwt [[-ClientId] <String>] [[-Issuer] <String>] [[-ClientSecret] <String>]
 [[-SecureClientSecret] <SecureString>] [-Scopes] <String[]> [<CommonParameters>]
```

## DESCRIPTION

## EXAMPLES

### Example 1
```powershell
Get-OktaAppJwt -ClientId $app.Id -ClientSecret $env:OKTA_CLIENT_SECRET -Scopes "access:token","object:read" -Issuer $authServer.issuer
```

Get the JWT for an App

## PARAMETERS

### -ClientId
A server Application's id, retrieved with Get-OktaApplication

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

### -ClientSecret
The Application's secret from the web site.

```yaml
Type: String
Parameter Sets: (All)
Aliases: Pw

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Issuer
Authorization server's Issuer

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

### -Scopes
The request scopes for the JWT

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SecureClientSecret
The Application's secret from the web site as a secure string.

```yaml
Type: SecureString
Parameter Sets: (All)
Aliases: Password

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.String as the JWT

## NOTES

## RELATED LINKS
