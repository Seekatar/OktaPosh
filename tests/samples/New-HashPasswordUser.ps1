# sample code to create a password hash for adding to Okta

$ErrorActionPreference = 'Stop'

Import-Module C:\code\OktaPosh\OktaPosh\OktaPosh.psd1 -fo

$pw = "testing123"
$salt = "this is the salt"
$pwValue = [System.Text.Encoding]::UTF8.GetBytes($pw)
$saltValue = [System.Text.Encoding]::UTF8.GetBytes($salt)

# in this case the hash is of password+salt hashed with SHA-256
$saltedValue = $pwValue + $saltValue
$hashValue = [System.Security.Cryptography.SHA256]::Create().ComputeHash($saltedValue)

# tell Okta how it is hashed
$passwordHash = @{
    hash = @{
      algorithm = "SHA-256"
      salt = ([System.Convert]::ToBase64String([System.Text.Encoding]::utf8.GetBytes($salt)))
      saltOrder = "POSTFIX"
      value = ([System.Convert]::ToBase64String($hashValue))
    }
  }

New-OktaUser -Login "test1234" -FirstName Test -LastName User -Email test-123@mailinator.com -PasswordHash $passwordHash

