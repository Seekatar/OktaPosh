---
external help file: OktaPosh-help.xml
Module Name: OktaPosh
online version:
schema: 2.0.0
---

# Get-OktaScope

## SYNOPSIS
Get one or more Scopes for an authorization server

## SYNTAX

### ById
```
Get-OktaScope -AuthorizationServerId <String> -ScopeId <String> [-IncludeSystem] [<CommonParameters>]
```

### Query
```
Get-OktaScope -AuthorizationServerId <String> [-Query <String>] [-IncludeSystem] [<CommonParameters>]
```

## EXAMPLES

### Example 1
```
PS C:\>
```
## PARAMETERS
### -AuthorizationServerId
<!-- #include ./params/authserverIdDescription.md -->

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

### -Query
Query for name and description

```yaml
Type: String
Parameter Sets: Query
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```



### -ScopeId
Okta Scope Id from search version of Get-OktaScope

```yaml
Type: String
Parameter Sets: ById
Aliases: id

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).


## INPUTS

### System.String
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS

