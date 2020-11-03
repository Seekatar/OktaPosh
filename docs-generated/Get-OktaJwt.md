---
external help file: OktaPosh-help.xml
Module Name: OktaPosh
online version:
schema: 2.0.0
---

# Get-OktaJwt

## SYNOPSIS
Get an Okta JWT token for an Application or Okta User

## SYNTAX

```
Get-OktaJwt [-ClientId <String>] [-Issuer <String>] [-RedirectUri <String>] [-Username <String>]
 [-ClientSecret <String>] [-SecureClientSecret <SecureString>] [-IdToken] -Scopes <String[]>
 -GrantType <String> [<CommonParameters>]
```

## DESCRIPTION
This only does client credentials flow for server and implicit for user

## EXAMPLES

### EXAMPLE 1
```
$env:OktaClientSecret="..."
Get-OktaJwt -ClientId "clientId" -Issuer https://dev-111111.okta.com/oauth2/aus3333333 -GrantType client_credentials -Scopes access:token
```

Get a token for an Application

### EXAMPLE 2
```
Get-OktaJwt -Issuer https://dev-111111.okta.com/oauth2/aus3333333 -ClientId clientId -RedirectUri http://localhost:8080/app/implicit/callback -Username Test -ClientSecret ****! -Scopes openid -GrantType implicit
```

Get a token for a user

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

### -ClientSecret
Client secret for the Application or user password

```yaml
Type: String
Parameter Sets: (All)
Aliases: Pw

Required: False
Position: Named
Default value: $env:OktaClientSecret
Accept pipeline input: False
Accept wildcard characters: False
```

### -SecureClientSecret
Client secret for the Application as a SecureString or user password

```yaml
Type: SecureString
Parameter Sets: (All)
Aliases: Password

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -GrantType
{{ Fill GrantType Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IdToken
{{ Fill IdToken Description }}

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

### -Issuer
Issuer URL for the Authorization Server

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RedirectUri
A redirect uri configured in the Application

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Scopes
One or more Scopes to request

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Username
Username of Okta user

```yaml
Type: String
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

### JWT string or null
## NOTES

## RELATED LINKS

