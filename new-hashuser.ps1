ipmo C:\code\OktaPosh\OktaPosh\OktaPosh.psd1 -fo

$passwordHash = @{
    hash = @{
        algorithm = 'SHA-1'
        saltOrder = "POSTFIX"
        salt = '8D1146DD-7639-490C75732C5'
        value = 'žB[¬þ•ÔI±¬÷0V^u³—¦8'
    }
}

New-OktaUser -Login azharul.hoque -FirstName Test -LastName User -Email test-123@mailinator.com -PasswordHash $passwordHash -verbose

