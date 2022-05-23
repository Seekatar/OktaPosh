<#
.SYNOPSIS
Import one or more user into Okta from a CSV file

.PARAMETER Path
Path to a CSV file. See notes for format of file.

.PARAMETER Application
Optional Okta application name to associate each user

.PARAMETER HashAlgorithm
How the Password field in the file should be interpreted. ClearText, SHA-512, SHA-256, SHA-1 or MD5

.PARAMETER SaltOrder
Specifies whether salt was pre- or post-fixed to the password before hashing. Only required for hashed passwords.

.PARAMETER Skip
To process part of the file, where to start. Defaults to 0

.PARAMETER Limit
Number of users to process. Defaults to 9999

.EXAMPLE
Import-CasualtyOktaUser.ps1 -UserCsv .\clear-text.csv -Application MyApp


.NOTES
The CSV file must have the following columns: Comment,FirstName,LastName,Login,Email,PasswordHash,Salt,Password,Groups.

Comment             - free form text, ignored in processing
FirstName,LastName  - Imported to Okta
Email               - The email associated with the login. May be used on multiple logins. This will get emails about login, password reset, etc.
Login               - The Okta login value. If not supplied, uses Email. This is the value for user login and may be the email.

For credentials, if none the following are supplied, it will assume a domain user. Otherwise PasswordHash+Salt or Password must be supplied

Password            - Value for password. See below.
Salt                - The base64-encoded salt value for Password if Password is hashed

Groups              - optional, additional comma-separated groups to add to the user. Trailing wildcard is supported
MustExist           - If set to Y, will error out if the user if it doesn't exist, but will add the Application and Groups if exists.

The value for password depends on the HashAlgorithm parameter. If it is ClearText the password will be the clear text. If ClearText and empty Okta send users an activation email. Otherwise, it must be the base64 encoded hash using the specified algorithm.

Example file.

Comment,FirstName,LastName,Login,Email,Password,Salt,Groups,MustExist

#>
function Import-OktaUser {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path $_ -Type Leaf })]
        [string] $Path,
        [string] $Application,
        [ValidateSet("ClearText", "Provider", "SHA-512", "SHA-256", "SHA-1", "MD5")]
        [string] $HashAlgorithm,
        [ValidateSet("PREFIX", "POSTFIX")]
        [string] $SaltOrder,
        [int] $Skip = 0,
        [int] $Limit = 999999
    )

    Set-StrictMode -Version Latest
    $prevErr = $ErrorActionPreference
    $ErrorActionPreference = "Continue"

    $prevInfo = $InformationPreference
    $InformationPreference = 'Continue'

    $groupCache = @{}

    # get the Okta groups that are on the csv user
    function _getCsvUserGroupIds {
        [CmdletBinding()]
        param (
            [Parameter(Mandatory)]
            $CsvUser
        )
        $groupIds = @()
        if ($CsvUser.Groups) {
            foreach ($g in $CsvUser.Groups -split ',') {
                $group = $groupCache[$g]
                if (!$group) {
                    $group = Get-OktaGroup -Search "profile.name eq `"$g`""
                    if (!$group) {
                        throw "Couldn't find group '$g' for user $($CsvUser.Login)"
                    } else {
                        $groupCache[$g] = $group
                    }
                }
                $groupIds += $group.Id
            }
        }
        return $groupIds
    }

    function _addUserWithHash {
        [CmdletBinding(SupportsShouldProcess)]
        param (
            [Parameter(Mandatory)]
            $User,
            $GroupIds
        )
        Write-Verbose "Adding $($User.Login) with hashed pw"

        $passwordHash = @{
            hash = @{
                algorithm = $HashAlgorithm
                salt      = $User.Salt
                saltOrder = $SaltOrder
                value     = $User.Password
            }
        }
        New-OktaUser -PasswordHash $passwordHash `
            -GroupIds $GroupIds `
            -FirstName $User.FirstName `
            -LastName $User.LastName `
            -Email $User.Email `
            -Login $User.Login `
            -WhatIf:$WhatIfPreference

    }

    function _addUser {
        [CmdletBinding(SupportsShouldProcess)]
        param (
            [Parameter(Mandatory)]
            $User,
            [Parameter(Mandatory)]
            $GroupIds
        )

        New-OktaUser `
            -Pw $User.Password `
            -GroupIds $GroupIds `
            -FirstName $User.FirstName `
            -LastName $User.LastName `
            -Email $User.Email `
            -Login $User.Login`
            -Activate:(![bool]($User.Password)) `
            -WhatIf:$WhatIfPreference
    }

    function _addProviderUser {
        [CmdletBinding(SupportsShouldProcess)]
        param (
            [Parameter(Mandatory)]
            $User,
            $GroupIds,
            $Provider
        )
        New-OktaAuthProviderUser -ProviderType $provider `
            -ProviderName AZURAD `
            -GroupIds $GroupIds `
            -FirstName $User.FirstName `
            -LastName $User.LastName `
            -Email $User.Email `
            -Login $User.Login`
            -WhatIf:$WhatIfPreference
    }

    function _addUserToApp {
        [CmdletBinding()]
        param (
            [Parameter(Mandatory)]
            $OktaUser,
            [Parameter(Mandatory)]
            $User,
            [Parameter(Mandatory)]
            $AppId
        )
        Write-Verbose "Adding user $($User.Login) to app $Application"

        $oktaUserAppId = @((Get-OktaUserApplication -UserId $oktaUser.id) | Select-Object -ExpandProperty id)
        foreach ($id in $AppId | Where-Object { $_ -notin $oktaUserAppId }) {
            $null = Add-OktaApplicationUser -AppId $id -UserId $oktaUser.id
            Write-Information "Added $login to application $id"
        }
    }

    # -- main -------------------------------------------------------------------------------------
    # -- main -------------------------------------------------------------------------------------
    # -- main -------------------------------------------------------------------------------------
    try {

        $app = $null
        $appGroups = @()

        $users = @(ConvertFrom-Csv (Get-Content $Path -Raw)) | Select-Object -First $Limit -Skip $Skip

        Write-Information "Read $($users.Count) users from '$Path'"

        if ($Application) {
            Write-Information "Getting groups for '$Application'"
            $app = @(Get-OktaApplication -q $appName | Where-Object { $_.label -eq $appName })
            if (!$app) {
                throw "Didn't get Okta Application with a prefix of '$appName'"
            } elseif ($app.Count -gt 1) {
                throw "Found more than one Okta Application with a prefix of '$appName'"
            } else {
                $appId = $app.id
            }
        }

        $rowCount = 0
        foreach ($csvUser in $users) {
            $rowCount += 1
            try {
                if (!$csvUser.FirstName -or !$csvUser.LastName -or !$csvUser.Email) {
                    Write-Warning "User in row $rowCount missing required FirstName, LastName or Email: $($csvUser.FirstName), $($csvUser.LastName), $($csvUser.Email)"
                    continue
                }
                if (!$csvUser.Login) {
                    $csvUser.Login = $csvUser.Email
                }
                $login = $csvUser.Login

                $groupIds = @(_getCsvUserGroupIds $csvUser)

                $oktaUser = @(Get-OktaUser -Login $login)
                Write-Verbose "After Get-OktaUser with login of $login and user is $csvUser and oktaUser is $oktaUser"

                if ($oktaUser) {
                    if ($oktaUser.count -gt 1) {
                        Write-Warning "Found multiple $($oktaUser.count) users for with login of '$login'. Skipping"
                        return
                    }
                    Write-Information "Found existing user $login"

                    # add to groups not in
                    $oktaUserGroupIds = (Get-OktaUserGroup -UserId $oktaUser.id).id
                    $adds = 0
                    foreach ($gid in $groupIds | Where-Object { $_ -notin $oktaUserGroupIds }) {
                        $null = Add-OktaGroupUser -GroupId $gId -UserId $oktaUser.id -WhatIf:$WhatIfPreference
                        Write-Information "Added $login to group $gid"
                        $adds += 1
                    }
                    if (!$adds) {
                        Write-Information "User already in the $($groupIds.Count) groups"
                    }
                    if ($oktaUser.status -ne 'ACTIVE') {
                        Write-Information "Activating existing user"
                        $null = Enable-OktaUser -UserId $oktaUser.id
                    }
                } elseif ($csvUser.MustExist -ne 'Y') {

                    Write-Information "Adding $login"

                    if ($HashAlgorithm -eq 'ClearText') {
                        $oktaUser = _addUser -User $csvUser -GroupIds @($groupIds | Select-Object -First 20)
                    } elseif ($HashAlgorithm -eq 'Provider') {
                        if (!$Provider) { throw "Must supply Provider if HashAlgorithm is Provider"}
                        $oktaUser = _addProviderUser -User $csvUser -Provider $Provider -GroupIds ($groupIds | Select-Object -First 20)
                    } elseif ($HashAlgorithm -eq 'None') {
                        $oktaUser = _addUserNoPassword -User $csvUser -GroupIds ($groupIds | Select-Object -First 20)
                    } elseif ($SaltOrder) {
                        $oktaUser = _addUserWithHash -User $csvUser -GroupIds ($groupIds | Select-Object -First 20)
                    } else {
                        throw "Must set SaltOrder if using a Hash."
                    }

                    if (!(Get-Member -InputObject $oktaUser -Name id)) {
                        Write-Warning "Got non-user back from add user: $($oktaUser.GetType())"
                        Write-Warning ($oktaUser | ConvertTo-Json -Depth 10)
                        $oktaUser = Get-OktaUser -Login $login
                    } elseif ($oktaUser && $oktaUser.status -ne 'PROVISIONED') {
                        # added disabled to avoid sending email
                        $null = Enable-OktaUser -UserId $oktaUser.id

                        if ($groupIds.Count -gt 20) {
                            foreach ($gid in ($groupIds | Select-Object -Skip 20)) {
                                $null = Add-OktaGroupUser -GroupId $gId -UserId $oktaUser.id -WhatIf:$WhatIfPreference
                                Write-Information "Added $login to group $gid"
                            }
                        }
                    }
                } else {
                    Write-Warning "User with login $login doesn't exist and MustExist is set to N, skipping"
                }

                if (!$WhatIfPreference -and $oktaUser -and $app) {
                    _addUserToApp -OktaUser $oktaUser -User $csvUser -AppId $app.Id
                }
            } catch {
                Write-Error "Error adding user:`n$_`n$($_.ScriptStackTrace)"
            }
        }
    } catch {
        Write-Error "$_`n$($_.ScriptStackTrace)"
    } finally {
        $InformationPreference = $prevInfo
        $ErrorActionPreference = $prevErr
    }
}