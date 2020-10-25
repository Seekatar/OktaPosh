---
external help file: OktaPosh-help.xml
Module Name: OktaPosh
online version:
schema: 2.0.0
---

# Get-OktaJwt

## SYNOPSIS
Get an Okta JWT token

## SYNTAX

### Clear
```
Get-OktaJwt [-ClientId <String>] [-OktaTokenUrl <String>] [-ClientSecret <String>] [<CommonParameters>]
```

### Secure
```
Get-OktaJwt [-ClientId <String>] [-OktaTokenUrl <String>] -SecureClientSecret <SecureString>
 [<CommonParameters>]
```

## DESCRIPTION
This only does the client credentials flow

## EXAMPLES

### EXAMPLE 1
```
$env:OktaClientSecret="..."
Get-OktaJwt -ClientId "0oap78eubPKbQCnEk4x6" -OktaTokenUrl "https://dev-671484.okta.com/oauth2/ausp6jwjzhUYrGJsG4x6/v1/token"
```

## PARAMETERS

### -ClientId
ClientId from the Application

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: $env:OktaClientId
Accept pipeline input: False
Accept wildcard characters: False
```

### -OktaTokenUrl
Url to get the token, e.g.
"https://dev-671484.okta.com/oauth2/default/v1/token"

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: $env:OktaTokenUrl
Accept pipeline input: False
Accept wildcard characters: False
```

### -ClientSecret
Client secret for the Application

```yaml
Type: String
Parameter Sets: Clear
Aliases:

Required: False
Position: Named
Default value: $env:OktaClientSecret
Accept pipeline input: False
Accept wildcard characters: False
```

### -SecureClientSecret
Client secret for the Application as a SecureString

```yaml
Type: SecureString
Parameter Sets: Secure
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

## OUTPUTS

### JWT string or null
## NOTES

## RELATED LINKS
