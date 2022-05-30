---
external help file: OktaPosh-help.xml
Module Name: OktaPosh
online version:
schema: 2.0.0
---

# Set-OktaReadOnly

## SYNOPSIS
Sets the current read-only setting that prevents calling write operations

## SYNTAX

```
Set-OktaReadOnly [[-ReadOnly] <Boolean>] [<CommonParameters>]
```

## DESCRIPTION
The default is false when OktaPosh is load.
When this is called with true (the default), any calls that write to Okta will throw an exception.

## EXAMPLES

### Example 1
```powershell
PS C:\> Set-OktaReadOnly
```

Turn on read only.

### Example 1
```powershell
PS C:\> Set-OktaReadOnly $false
```

Turn off read only.

## PARAMETERS

### -ReadOnly
The value to set.
It defaults to true.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
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
