---
external help file: OktaPosh-help.xml
Module Name: OktaPosh
online version: https://developer.okta.com/blog/2021/03/05/ultimate-guide-to-password-hashing-in-okta
schema: 2.0.0
---

# New-OktaUser

## SYNOPSIS
Create a new user in Okta, with or without a password

## SYNTAX

```
New-OktaUser [-FirstName] <String> [-LastName] <String> [-Email] <String> [[-Login] <String>]
 [[-MobilePhone] <String>] [-Activate] [[-Pw] <String>] [-GroupIds <String[]>] [-NextLogin]
 [-RecoveryQuestion <String>] [-RecoveryAnswer <String>] [-PasswordHash <Hashtable>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION

## EXAMPLES

### Example 1
```
New-OktaUser -FirstName test-user -LastName test-user -Email $email
```

Add a new user without a password.
If activated an email is sent to the user.

### Example 2
```
New-OktaUser -FirstName test -LastName user -email test@mailinator.com -GroupIds '00g2903fezLwplKw14x7','00g2903fey8I2DoxQ4x7'
```

Add a new user, and add the user to groups

### Example 2
```
$pw = "testing123"
$salt = "this is the salt"
$value = [System.Text.Encoding]::UTF8.GetBytes($pw)
$saltValue = [System.Text.Encoding]::UTF8.GetBytes($salt)

$saltedValue = $value + $saltValue

$pwValue = [System.Security.Cryptography.SHA256]::Create().ComputeHash($saltedValue)

$passwordHash = @{
    hash = @{
      algorithm = "SHA-256"
      salt = ([System.Convert]::ToBase64String([System.Text.Encoding]::utf8.GetBytes($salt)))
      saltOrder = "POSTFIX"
      value = ([System.Convert]::ToBase64String($pwValue))
    }
  }

New-OktaUser -Login "test1234" -FirstName Test -LastName User -Email test-123@mailinator.com -PasswordHash $passwordHash -verbose
```

Add a new user with a SHA-256 salted password

## PARAMETERS

### -Activate
Set to activate during add.
An email will be sent to the user.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: True (ByPropertyName)
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
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Email
Email address

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -FirstName
First name

```yaml
Type: String
Parameter Sets: (All)
Aliases: given_name

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -LastName
Last name

```yaml
Type: String
Parameter Sets: (All)
Aliases: family_name

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Login
Login, defaults to Email

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -MobilePhone
Mobile Phone

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Pw
Optional initial password

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: True (ByPropertyName)
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

### -GroupIds
Optional array of groups to add the user to

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -NextLogin
If Activate is set, for user to change password at next login.

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

### -RecoveryAnswer
RecoveryQuestion answer.
Must be at least four characters.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -RecoveryQuestion
Password recovery question

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -PasswordHash
HashTable of password hash settings.
See notes and examples

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

### PSCustomObject
Object with FirstName, LastName, Email and optional Login, MobilePhone, Activate

## OUTPUTS

### PSCustomObject
User object

## NOTES
If you add a user with -Activate an email will be sent to the user.
In situations where you set the password, or for Federated users, you can avoid sending the email by adding the user without -Active, then calling Enable-User immediately afterwards.

For adding with a hash, see the related links for the data in the hashtable for various algorithms

## RELATED LINKS

[The Ultimate Guide to Password Hashing in Okta](https://developer.okta.com/blog/2021/03/05/ultimate-guide-to-password-hashing-in-okta)
[Creating user with hashed password](https://developer.okta.com/docs/reference/api/users/#create-user-with-imported-hashed-password)