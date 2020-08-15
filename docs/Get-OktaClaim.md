---
external help file: OktaPosh-help.xml
Module Name: OktaPosh
online version:
schema: 2.0.0
---

# Get-OktaClaim

## SYNOPSIS
{{ Fill in the Synopsis }}

## SYNTAX

### ById
```
Get-OktaClaim -AuthorizationServerId <String> -ClaimId <String> [<CommonParameters>]
```

### Query
```
Get-OktaClaim -AuthorizationServerId <String> [-Query <String>] [<CommonParameters>]
```

## DESCRIPTION


## EXAMPLES

### Example 1
```powershell
PS C:\> Get-OktaClaim -AuthorizationServerId $id
```

Get all the claims for that authorization server

## PARAMETERS
<!-- #include "./params/authServerId.md" -->

<!-- #include "./params/claimId.md" -->

### -Query
{{ Fill Query Description }}

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

### System.String

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
