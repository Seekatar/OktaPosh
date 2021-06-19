. C:\code\PoshStuff\base64.ps1

$ErrorActionPreference = 'Stop'

ipmo C:\code\OktaPosh\OktaPosh\OktaPosh.psd1 -fo

$pw = "testing123"
$salt = "this is the salt"
$value = [System.Text.Encoding]::UTF8.GetBytes($pw)
$saltValue = [System.Text.Encoding]::UTF8.GetBytes($salt)

$saltedValue = $value + $saltValue

$pwValue = (New-Object 'System.Security.Cryptography.SHA256Managed').ComputeHash($saltedValue)

$passwordHash = @{
    hash = @{
      algorithm = "SHA-256"
      salt = ([System.Convert]::ToBase64String([System.Text.Encoding]::utf8.GetBytes($salt)))
      saltOrder = "POSTFIX"
      value = ([System.Convert]::ToBase64String($pwValue))
    }
  }

New-OktaUser -Login "test1234" -FirstName Test -LastName User -Email test-123@mailinator.com -PasswordHash $passwordHash

