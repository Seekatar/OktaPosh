BeforeAll {
    . (Join-Path $PSScriptRoot '../setup.ps1') -Unit
}

# Pester 5 need to pass in TestCases object to pass share
$PSDefaultParameterValues = @{
    "It:TestCases" = @{
                        email = 'testuser@mailinator.com'
                        email2 = 'testuser2@mailinator.com'
                        primaryLink = "boss"
                        associatedLink = "minon"
                        vars = @{
                            user = @{id = '00u3mo3swhHpQbzOw4u7';profile=@{email="test";login="login"}}
                            user2 = @{id = '00u3mo3swhHpQbzOw4u7';profile=@{email="test";login="login"}}
                            group = @{id = "00g3mo3swhHpQbzOw4u7";profile=@{description="test"}}
                        }
    }
}

Describe "Cleanup" {
    It "Remove test user" {
    }
}

Describe "User" {
    It "Adds a user" {
        $null = New-OktaUser -FirstName test-user -LastName test-user -Email $email
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/users?activate=false" -and $Method -eq 'POST'
                }
    }
    It "Adds a with hashed pw" {
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

        $null = New-OktaUser -Login $email -FirstName Test -LastName User -Email $email -PasswordHash $passwordHash
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/users?activate=false" -and $Method -eq 'POST'
                }
    }
    It "Tries to use pw and has" {
        { New-OktaUser -Login $email -FirstName Test -LastName User -Email $email -PasswordHash @{} -Pw 'test' } | Should -Throw 'Can''t supply both*'
    }
    It "Adds a user with recovery question" {
        $null = New-OktaUser -FirstName test-user -LastName test-user -Email $email -RecoveryQuestion Why? -RecoveryAnswer "Answer is 42"
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $b = $Body | ConvertFrom-Json
                    $Uri -like "*/users?activate=false" -and $Method -eq 'POST' -and $b.credentials.recovery_question.question -eq 'Why?'
                }
    }
    It "Adds a user to login next" {
        $null = New-OktaUser -FirstName test-user -LastName test-user -Email $email -NextLogin -Activate
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/users?activate=true&nextLogin=changePassword" -and $Method -eq 'POST'
                }
    }
    It "Adds a user to a group" {
        $null = New-OktaUser -FirstName test-user -LastName test-user -Email $email -GroupIds @($vars.group.id)
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $b = $Body | ConvertFrom-Json
                    $Uri -like "*/users?activate=false" -and $Method -eq 'POST' -and $b.groupIds[0] -eq $vars.group.id
                }
    }
    It "Adds AuthProviderUser" {
        $null = New-OktaAuthProviderUser -FirstName "fn" -LastName "ln" -Email "OktaPosh-test-user@mailinator.com" -ProviderType SOCIAL
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/users?activate=false&provider=true*" -and $Method -eq 'POST'
                }
    }
    It "Adds AuthProviderUser to loginNext" {
        $null = New-OktaAuthProviderUser -FirstName "fn" -LastName "ln" -Email "OktaPosh-test-user@mailinator.com" -ProviderType SOCIAL -Activate
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/users?activate=true&provider=true" -and $Method -eq 'POST'
                }
    }
    It "Gets Users" {
        $null = @(Get-OktaUser)
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/users" -and $Method -eq 'GET'
                }
    }
    It "Gets Next Users" {
        Mock -CommandName Invoke-WebRequest `
        -ModuleName OktaPosh `
        -MockWith {
            $Response = New-MockObject -Type  Microsoft.PowerShell.Commands.WebResponseObject
            $Content = '{"errorCode": "200", "name":"test", "system": "system", "id": "policyid", "access_token": "token", "sessionToken": "token" }'
            $StatusCode = 200

            $Response | Add-Member -NotePropertyName Headers -NotePropertyValue @{
                link =  '<https://devcccis.oktapreview.com/api/v1/users?limit=3>; rel="self" <https://devcccis.oktapreview.com/api/v1/users?after=100uqe1z1959wX4LxJ0h7&limit=3>; rel="next"'
            } -Force
            if ($PSVersionTable.PSVersion.Major -ge 7) {
                $Response | Add-Member -NotePropertyName RelationLink -NotePropertyValue @{} -Force
            }
            $Response | Add-Member -NotePropertyName Content -NotePropertyValue $Content -Force
            $Response | Add-Member -NotePropertyName StatusCode -NotePropertyValue $StatusCode -Force
            $Response
        }
        $null = @(Get-OktaUser -Limit 1)
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/users?limit=1" -and $Method -eq 'GET'
                }
        Test-OktaNext -ObjectName users | Should -BeTrue
        Mock -CommandName Invoke-WebRequest `
            -ModuleName OktaPosh `
            -MockWith {
                $Response = New-MockObject -Type  Microsoft.PowerShell.Commands.WebResponseObject
                $Content = '{"errorCode": "200", "name":"test", "system": "system", "id": "policyid", "access_token": "token", "sessionToken": "token" }'
                $StatusCode = 200

                $Response | Add-Member -NotePropertyName Headers -NotePropertyValue @{} -Force
                if ($PSVersionTable.PSVersion.Major -ge 7) {
                    $Response | Add-Member -NotePropertyName RelationLink -NotePropertyValue @{} -Force
                }
                $Response | Add-Member -NotePropertyName Content -NotePropertyValue $Content -Force
                $Response | Add-Member -NotePropertyName StatusCode -NotePropertyValue $StatusCode -Force
                $Response
            }
        $null = @(Get-OktaUser -Next)
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/users?after=*" -and $Method -eq 'GET'
                }
        Test-OktaNext -ObjectName users | Should -BeFalse
        $null = @(Get-OktaUser -Next) 3> $null
        Should -Invoke Invoke-WebRequest -Times 2 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/users*" -and $Method -eq 'GET'
                }
    }
    It "Tests Next" {
        Test-OktaNext -ObjectName users | Should -BeFalse
        (Get-OktaNextUrl).Keys.Count | Should -Be 0
    }
    It "Tests RateLimit" {
        (Get-OktaRateLimit).RateLimit | Should -Be $null
    }
    It "Gets User By Email" {
        $null = Get-OktaUser -Query $email
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    # For PS5 uri is not encoded, PS7 it is
                    $Uri -like '*/users?q=testuser*mailinator.com' -and $Method -eq 'GET'
                }
    }
    It "Gets User By Id" {
        $null = Get-OktaUser -Id $vars.user.Id
        $null = Get-OktaUser -Query $vars.user.Id
        Should -Invoke Invoke-WebRequest -Times 2 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/users/$($vars.user.Id)" -and $Method -eq 'GET'
                }
    }
    It "Updates a User" {
        $null = Set-OktaUser $vars.user
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/users/$($vars.user.Id)" -and $Method -eq 'PUT'
                }
    }
    It "Activates a user" {
        Mock -CommandName Invoke-WebRequest `
            -ModuleName OktaPosh `
            -MockWith {
                $Response = New-MockObject -Type  Microsoft.PowerShell.Commands.WebResponseObject
                $Content = '{"errorCode": "200", "Status":"STAGED" }'
                $StatusCode = 200

                $Response | Add-Member -NotePropertyName Headers -NotePropertyValue @{} -Force
                if ($PSVersionTable.PSVersion.Major -ge 7) {
                    $Response | Add-Member -NotePropertyName RelationLink -NotePropertyValue @{} -Force
                }
                $Response | Add-Member -NotePropertyName Content -NotePropertyValue $Content -Force
                $Response | Add-Member -NotePropertyName StatusCode -NotePropertyValue $StatusCode -Force
                $Response
            }

        $null = Enable-OktaUser -Id $vars.user.Id
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/users/$($vars.user.Id)/lifecycle/*activate?sendEmail=false" -and $Method -eq 'POST'
                }
    }
    It "Suspends a user" {
        Mock -CommandName Invoke-WebRequest `
            -ModuleName OktaPosh `
            -MockWith {
                $Response = New-MockObject -Type  Microsoft.PowerShell.Commands.WebResponseObject
                $Content = '{"errorCode": "200", "Status":"ACTIVE" }'
                $StatusCode = 200

                $Response | Add-Member -NotePropertyName Headers -NotePropertyValue @{} -Force
                if ($PSVersionTable.PSVersion.Major -ge 7) {
                    $Response | Add-Member -NotePropertyName RelationLink -NotePropertyValue @{} -Force
                }
                $Response | Add-Member -NotePropertyName Content -NotePropertyValue $Content -Force
                $Response | Add-Member -NotePropertyName StatusCode -NotePropertyValue $StatusCode -Force
                $Response
            }

        $null = Suspend-OktaUser -Id $vars.user.Id -CheckCurrentStatus
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/users/$($vars.user.Id)/lifecycle/suspend" -and $Method -eq 'POST'
                }
    }
    It "Resumes a user" {
        Mock -CommandName Invoke-WebRequest `
            -ModuleName OktaPosh `
            -MockWith {
                $Response = New-MockObject -Type  Microsoft.PowerShell.Commands.WebResponseObject
                $Content = '{"errorCode": "200", "Status":"SUSPENDED" }'
                $StatusCode = 200

                $Response | Add-Member -NotePropertyName Headers -NotePropertyValue @{} -Force
                if ($PSVersionTable.PSVersion.Major -ge 7) {
                    $Response | Add-Member -NotePropertyName RelationLink -NotePropertyValue @{} -Force
                }
                $Response | Add-Member -NotePropertyName Content -NotePropertyValue $Content -Force
                $Response | Add-Member -NotePropertyName StatusCode -NotePropertyValue $StatusCode -Force
                $Response
            }

        $null = Resume-OktaUser -Id $vars.user.Id -CheckCurrentStatus
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/users/$($vars.user.Id)/lifecycle/unsuspend" -and $Method -eq 'POST'
                }
    }
    It "Deactivates a user" {
        Mock -CommandName Invoke-WebRequest `
            -ModuleName OktaPosh `
            -MockWith {
                $Response = New-MockObject -Type  Microsoft.PowerShell.Commands.WebResponseObject
                $Content = '{"errorCode": "200", "Status":"ACTIVE" }'
                $StatusCode = 200

                $Response | Add-Member -NotePropertyName Headers -NotePropertyValue @{} -Force
                if ($PSVersionTable.PSVersion.Major -ge 7) {
                    $Response | Add-Member -NotePropertyName RelationLink -NotePropertyValue @{} -Force
                }
                $Response | Add-Member -NotePropertyName Content -NotePropertyValue $Content -Force
                $Response | Add-Member -NotePropertyName StatusCode -NotePropertyValue $StatusCode -Force
                $Response
            }

        $null = Disable-OktaUser -Id $vars.user.Id -Confirm:$false
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/users/$($vars.user.Id)/lifecycle/deactivate?sendEmail=false" -and $Method -eq 'POST'
                }
    }
    It "Clears sessions" {
        $null = Remove-OktaUserSession -UserId $vars.user.id -Confirm:$false
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/users/$($vars.user.id)/sessions?oauthTokens=false" -and $Method -eq 'DELETE'
                }
    }
    It "Reset MFA" {
        $null = Reset-OktaUserMfa -UserId $vars.user.id
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/users/$($vars.user.id)/lifecycle/reset_factors" -and $Method -eq 'POST'
                }
    }
    It "Sets RecoveryQuestion" {
        $null = Set-OktaUserRecoveryQuestion -UserId $vars.user.id -Pw oldPw -Question Why -Answer Because
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/users/$($vars.user.id)/credentials/change_recovery_question" -and $Method -eq 'POST'
                }
    }
    It "Reset Password with answer" {
        $null = Reset-OktaPasswordWithAnswer -UserId $vars.user.id -Answer test -NewPw test
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/users/$($vars.user.id)/credentials/forgot_password" -and $Method -eq 'POST'
                }
    }
    It "Sets Password" {
        $null = Set-OktaPassword -UserId $vars.user.id -OldPw oldPw -NewPw newPw
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/users/$($vars.user.id)/credentials/change_password?strict=false" -and $Method -eq 'POST'
                }
    }
    It "Reset Password" {
        $null = Reset-OktaPassword -UserId $vars.user.id
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/users/$($vars.user.id)/lifecycle/reset_password?sendEmail=false" -and $Method -eq 'POST'
                }
    }
    It "Unlocks a user" {
        $null = Unlock-OktaUser -UserId $vars.user.id
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/users/$($vars.user.id)/lifecycle/unlock" -and $Method -eq 'POST'
                }
    }
    It "Revoke a password" {
        $null = Revoke-OktaPassword -UserId $vars.user.id
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/users/$($vars.user.id)/lifecycle/expire_password?tempPassword=false" -and $Method -eq 'POST'
                }
    }
    # It "Convert to Federated" {
    #     $null = Convert-OktaUserToFederated -UserId $vars.user.id
    #     Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
    #             -ParameterFilter {
    #                 $Uri -like "*/users/$($vars.user.id)/lifecycle/reset_password?provider=FEDERATION&sendEmail=false" -and $Method -eq 'POST'
    #             }
    # }
}

Describe "LinkTests" {
    It 'Creates a link definition' {
        $null = New-OktaLinkDefinition -PrimaryTitle $primaryLink -AssociatedTitle $associatedLink
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/meta/schemas/user/linkedObjects" -and $Method -eq 'POST'
                }
    }
    It 'Gets a link definition by primary' {
        $null = Get-OktaLinkDefinition -PrimaryName $primaryLink
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*meta/schemas/user/linkedObjects/$primaryLink" -and $Method -eq 'GET'
                }
    }
    It 'Gets a link definition by associated' {
        $null = Get-OktaLinkDefinition -PrimaryName $associatedLink
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*meta/schemas/user/linkedObjects/$associatedLink" -and $Method -eq 'GET'
                }
    }
    It 'Gets all link definitions' {
        $null = @(Get-OktaLinkDefinition)
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*meta/schemas/user/linkedObjects" -and $Method -eq 'GET'
                }
    }
    It 'Links two users to one' {
        $null = Set-OktaLink -PrimaryUserId $vars.user.id -AssociatedUserId $vars.user2.id -PrimaryName $primaryLink
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*users/$($vars.user2.id)/linkedObjects/$primaryLink/$($vars.user.id)" -and $Method -eq 'PUT'
                }
    }
    It 'Gets primary user link' {
        $null = Get-OktaLink -UserId $vars.user.id -LinkName $associatedLink
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*users/$($vars.user.id)/linkedObjects/$associatedLink" -and $Method -eq 'GET'
                }
    }
    It 'Gets primary user link as objects' {
        $null = Get-OktaLink -UserId $vars.user.id -LinkName $associatedLink -GetUser
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*users/$($vars.user.id)/linkedObjects/$associatedLink" -and $Method -eq 'GET'
                }
    }
    It 'Gets associate user link' {
        $ids = @(Get-OktaLink -UserId $vars.user2.id -LinkName $primaryLink)
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*users/$($vars.user2.id)/linkedObjects/$primaryLink" -and $Method -eq 'GET'
                }
    }
}


Describe "Cleanup" {
    It "Remove test user" {
        Remove-OktaLinkDefinition -PrimaryName $primaryLink -Confirm:$false
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*meta/schemas/user/linkedObjects/$primaryLink" -and $Method -eq 'DELETE'
                }

        Mock Get-OktaUser -ModuleName OktaPosh -MockWith { @{profile=@{email='test';login='test'};Status='PROVISIONED'}}
        Remove-OktaUser -UserId $vars.user.id -Confirm:$false
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/users/$($vars.user.Id)" -and $Method -eq 'DELETE'
                }
        $null = Remove-OktaLink -UserId $vars.user2.id -PrimaryName $primaryLink -Confirm:$false
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*users/$($vars.user2.id)/linkedObjects/$primaryLink" -and $Method -eq 'DELETE'
                }
        }
}

