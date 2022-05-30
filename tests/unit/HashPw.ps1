function hashPw(
    [Parameter(Mandatory)]
    [string] $pw,
    [string] $salt = "salty",
    [switch] $Postfix,
    [ValidateSet("BCRYPT", "SHA-512", "SHA-256", "SHA-1", "MD5")]
    [string] $HashAlgorithm

) {
    $value = [System.Text.Encoding]::UTF8.GetBytes($pw)
    $saltValue = [System.Text.Encoding]::UTF8.GetBytes($salt)

    if ($Postfix) {
        $saltedValue = $value + $saltValue
    } else {
        $saltedValue = $saltValue + $value
    }

    switch ($HashAlgorithm) {
        "SHA-512" {
            $hash = [System.Security.Cryptography.SHA512]::Create().ComputeHash($saltedValue)
        }
        "SHA-256" {
            $hash = [System.Security.Cryptography.SHA256]::Create().ComputeHash($saltedValue)
        }
        "SHA-1" {
            $hash = [System.Security.Cryptography.SHA1]::Create().ComputeHash($saltedValue)
        }
        "MD5" {
            $hash = [System.Security.Cryptography.MD5]::Create().ComputeHash($saltedValue)
        }
        Default {
            throw "What?!"
        }
    }

    base64 -Value $hash -Wrap 0
    base64 -Value $salt -Wrap 0
}
