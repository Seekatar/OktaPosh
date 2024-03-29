---
external help file: OktaPosh-help.xml
Module Name: OktaPosh
online version: https://github.com/Seekatar/OktaPosh/blob/main/README.md
schema: 2.0.0
---

# Invoke-OktaApi

## SYNOPSIS
Helper for calling the OktaApi.
Mainly used internally.

## SYNTAX

```
Invoke-OktaApi [-RelativeUri] <String> [[-Method] <String>] [[-Body] <Object>] [-Json]
 [[-OktaApiToken] <String>] [[-OktaBaseUri] <String>] [-Next] [-NotFoundOk] [-NoRetryOnLimit] [-NoWarn]
 [-AdditionalHeaders <Hashtable>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
This calls the API and returns the object or error messages.
You can use this to call APIs that are not yet in this module.

## EXAMPLES

### Example 1
```
Invoke-OktaApi -RelativeUri "apps?filter=user.id+eq+%2200upwxy3icQiHJ3HN0h7%22+or+status+eq+%22ACTIVE%22&expand=user%2F00upwxy3icQiHJ3HN0h7&limit=25" -Verbose
```

This was lifted from the browser's dev tools to figure out how it was getting a user's apps.
This was then turned into Get-OktaUserApplication

### Example 1
```
Invoke-OktaApi -RelativeUri users/00....7/factors
```

Get a user's factors, which wasn't supported yet with a separate function.

## PARAMETERS

### -Body
The string version of the body to send for post, put, patch

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

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

### -Json
Set to return raw content instead of converting from JSON to objects

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

### -Method
The HTTP method to use

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: Get, Head, Post, Put, Delete, Trace, Options, Merge, Patch

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Next
Set to get the next page from a previous call (if one exists)

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

### -NoRetryOnLimit
Set to false to fail on rate limit error, otherwise will wait and retry

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

### -NotFoundOk
Set if a non-Get call is ok to get 404, otherwise non-Get 404 will result in an error.

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

### -OktaApiToken
The API token.
Calls Get-OktaApiToken with this value so if blank will use value from Set-OktaOption, or environment, if they exist.

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

### -OktaBaseUri
The base API Uri.
Calls Get-OktaBaseUri with this value so if blank will use value from Set-OktaOption, or environment, if they exist.

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

### -RelativeUri
Additional part of Uri to call, after base.

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

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -NoWarn
For -Next when no results, do not show warning

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

### -AdditionalHeaders
Any additional headers to add to the request

```yaml
Type: Hashtable
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

### System.Object
## NOTES

## RELATED LINKS
