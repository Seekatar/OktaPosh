---
external help file: OktaPosh-help.xml
Module Name: OktaPosh
online version:
schema: 2.0.0
---

# Get-OktaApplicationUser

## SYNOPSIS
Get one or more users attached to the application

## SYNTAX

### Query (Default)
```
Get-OktaApplicationUser -AppId <String> [-Query <String>] [-Limit <UInt32>] [-Json] [<CommonParameters>]
```

### ById
```
Get-OktaApplicationUser -AppId <String> -UserId <String> [-Json] [<CommonParameters>]
```

### Next
```
Get-OktaApplicationUser -AppId <String> [-Next] [-Json] [-NoWarn][<CommonParameters>]
```

## DESCRIPTION

## EXAMPLES

### EXAMPLE 1
```
$app = Get-OktaApplication MyApp
$users = Get-OktaApplicationUser -AppId $app.id -limit 10
while (Test-OktaNext -ObjectName "apps/$($app.id)/users" ) { $users += Get-OktaApplicationUser -AppId $app.id -Next; $users.Count }​​​​​​
$users.credentials.username | Sort-Object
```

Get all the users for MyApp

## PARAMETERS

### -AppId
ApplicationId retrieved from Get-OktaApplication

```yaml
Type: String
Parameter Sets: (All)
Aliases: ApplicationId

Required: True
Position: Named
Default value: None
Accept pipeline input: False
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

### -Limit
Specifies the number of results to return

```yaml
Type: UInt32
Parameter Sets: Query
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Next
Set to get the next page from a previous call (if one exists)

```yaml
Type: SwitchParameter
Parameter Sets: Next
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Query
Value matched against an application user profile's userName, firstName, lastName, and email.
Note: This operation only supports startsWith that matches what the string starts with to the query.

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

### -UserId
UserId retrieved from Get-OktaUser

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

### -NoWarn
For -Next when no results, do not show warning

```yaml
Type: SwitchParameter
Parameter Sets: Next
Aliases:

Required: False
Position: Named
Default value: False
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
User objects

## NOTES

## RELATED LINKS
