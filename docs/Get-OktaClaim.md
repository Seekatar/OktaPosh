---
external help file: OktaPosh-help.xml
Module Name: OktaPosh
online version:
schema: 2.0.0
---

# Get-OktaClaim

## SYNOPSIS
Get one of more Claims for an AuthorizationServer

## SYNTAX

### Query (Default)
```
Get-OktaClaim -AuthorizationServerId <String> [-Query <String>] [-Json] [<CommonParameters>]
```

### ById
```
Get-OktaClaim -AuthorizationServerId <String> -ClaimId <String> [-Json] [<CommonParameters>]
```

## DESCRIPTION

## EXAMPLES

### Example 1
```
PS C:\> Get-OktaClaim -AuthorizationServerId $id
```

Get all the claims for that authorization server

## PARAMETERS

### -AuthorizationServerId
AuthorizationServerId retrieved from Get-OktaAuthorizationServer

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

### -ClaimId
ClaimId for an Authorization Server

```yaml
Type: String
Parameter Sets: ById
Aliases: Id

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Json
Set to return JSON instead of PSCustomObject

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
Searches within the name within the results

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### String
Pipe Ids in

### PSCustomObject[]
Pipe objects with Id

## OUTPUTS

### PSCustomObject[]
Claim objects

## NOTES

## RELATED LINKS
