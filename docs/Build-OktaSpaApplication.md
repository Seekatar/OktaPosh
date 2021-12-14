---
external help file: OktaPosh-help.xml
Module Name: OktaPosh
online version:
schema: 2.0.0
---

# Build-OktaSpaApplication

## SYNOPSIS
Helper to create an spa application

## SYNTAX

```
Build-OktaSpaApplication [-Label] <String> [-RedirectUris] <String[]> [-LoginUri] <String>
 [[-PostLogoutUris] <String[]>] [-Inactive] [[-SignOnMode] <String>] [[-Properties] <Hashtable>]
 [[-GrantTypes] <String[]>] [-AuthServerId] <String> [[-Scopes] <String[]>] [-Quiet] [<CommonParameters>]
```

## DESCRIPTION
This will create a spa server if it doesn't exist, and if it does exist will update the uris, grant types, ans response types.
It will also add a \<appName\>-Policy policy to the auth server and add an allow rule.

## EXAMPLES

### Example 1
```powershell
        Build-OktaSpaApplication `
            -Label testAppName `
            -RedirectUris 'https://a.test.com','https://b.test.com' `
            -LoginUri 'https://l.test.com' `
            -PostLogoutUris 'https://c.test.com','https://d.test.com' `
            -SignOnMode "OPENID_CONNECT" `
            -GrantTypes 'implicit','authorization_code' `
            -Scopes 'scope:test1','scope:test2' `
            -AuthServerId $auth.id

```

Adds test application, or updates it.

## PARAMETERS

### -AuthServerId
AuthorizationServerId retrieved from Get-OktaAuthorizationServer

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 7
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -GrantTypes
Types of grant for the Rule

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:
Accepted values: implicit, authorization_code, refresh_token

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Inactive
Set to add as inactive

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

### -Label
Unique user-defined display name for app

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

### -LoginUri
Initiate login URI

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PostLogoutUris
URIs where Okta will send relying party initiated logouts.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Properties
Optional properties to attach

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RedirectUris
URIs where Okta will send relying party initiated logouts.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Scopes
Array of scope names to allow

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 8
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SignOnMode
Authentication mode of app (see https://developer.okta.com/docs/reference/api/apps/#sign-on-modes)

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Quiet
Do not write out informational messages

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

### None

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
