---
external help file: OktaPosh-help.xml
Module Name: OktaPosh
online version: https://github.com/Seekatar/OktaPosh/blob/main/README.md
schema: 2.0.0
---

# Import-OktaUser

## SYNOPSIS
Import one or more user into Okta from a CSV file

## SYNTAX

```
Import-OktaUser [-Path] <String> [[-AppName] <String>] [[-HashAlgorithm] <String>] [[-SaltOrder] <String>]
 [[-Skip] <Int32>] [[-Limit] <Int32>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION


## EXAMPLES

### EXAMPLE 1
```
Import-OktaUser -Path '/user-import/clear-text.csv' -HashAlgorithm ClearText -Limit 2
```

Import 2 users from the clear-text.csv file

### EXAMPLE 1
```
Import-OktaUser -Path (Join-Path $PSScriptRoot 'user-import/no-pw.csv') -HashAlgorithm ClearText -Limit 2 -AppName "OktaPosh-test-user-import"
```

Import 2 users from no-pw.csv and attach to a specific app

## PARAMETERS

### -Path
Path to a CSV file.
See notes for format of file.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AppName
Optional Okta application name to associate each user

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -HashAlgorithm
How the Password field in the file should be interpreted.
ClearText, SHA-512, SHA-256, SHA-1 or MD5

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

### -SaltOrder
Specifies whether salt was pre- or post-fixed to the password before hashing.
Only required for hashed passwords.

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

### -Skip
To process part of the file, where to start.
Defaults to 0

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Limit
Number of users to process.
Defaults to 9999

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: 999999
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
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

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

## NOTES
The CSV file must have the following columns: Comment,FirstName,LastName,Login,Email,PasswordHash,Salt,Password,Groups.

Comment             - free form text, ignored in processing
FirstName,LastName  - Imported to Okta
Email               - The email associated with the login.
May be used on multiple logins.
This will get emails about login, password reset, etc.
Login               - The Okta login value.
If not supplied, uses Email.
This is the value for user login and may be the email.

For credentials, if none the following are supplied, it will assume a domain user.
Otherwise PasswordHash+Salt or Password must be supplied

Password            - Value for password.
See below.
Salt                - The base64-encoded salt value for Password if Password is hashed

Groups              - optional, additional comma-separated groups to add to the user.
Trailing wildcard is supported
MustExist           - If set to Y, will error out if the user if it doesn't exist, but will add the Application and Groups if exists.

The value for password depends on the HashAlgorithm parameter.
If it is ClearText the password will be the clear text.
If ClearText and empty Okta send users an activation email.
Otherwise, it must be the base64 encoded hash using the specified algorithm.

Example file. (More sample files in the [repo](https://github.com/Seekatar/OktaPosh/tree/main/tests/integration/user-import))

Comment,FirstName,LastName,Login,Email,Password,Salt,Groups,MustExist
"Add a user with email and login, but no pw","Gordon","Roberts","gordon.roberts@mailinator.com","okta-test-groberts","","","","N"
"Add user to a group, but no pw","Alison","Hart","okta-test-ahart@mailinator.com","okta-test-ahart","","","OktaPosh-test-user-import","N"
"Add a user with a clear-text pw","Adam","Butler","adam.butler@mailinator.com","okta-test-abutler","J4ByGCcu2RDT","","OktaPosh-test-user-import","N"


## RELATED LINKS
