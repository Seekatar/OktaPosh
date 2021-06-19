BeforeAll {
    . (Join-Path $PSScriptRoot '../setup.ps1') -Unit
}

# Pester 5 need to pass in TestCases object to pass share
$PSDefaultParameterValues = @{
    "It:TestCases" = @{
                        email = 'testuser@mailinator.com'
                        email2 = 'testuser2@mailinator.com'
                        vars = @{
                            user = @{id = '123-234'}
                            user2 = @{id = '123-235'}
                            group = @{id = "123-123-345";profile=@{description="test"}}
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

        $pwValue = (New-Object 'System.Security.Cryptography.SHA256Managed').ComputeHash($saltedValue)

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
        $null = New-OktaAuthProviderUser -FirstName "fn" -LastName "ln" -Email "test-user@mailinator.com" -ProviderType SOCIAL
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/users?activate=false&provider=true*" -and $Method -eq 'POST'
                }
    }
    It "Adds AuthProviderUser to loginNext" {
        $null = New-OktaAuthProviderUser -FirstName "fn" -LastName "ln" -Email "test-user@mailinator.com" -ProviderType SOCIAL -Activate
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
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
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

        $null = Disable-OktaUser -Id $vars.user.Id
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/users/$($vars.user.Id)/lifecycle/deactivate?sendEmail=false" -and $Method -eq 'POST'
                }
    }
}

Describe "Cleanup" {
    It "Remove test user" {
        Mock Get-OktaUser -ModuleName OktaPosh -MockWith { @{profile=@{email='test';login='test'};Status='PROVISIONED'}}
        Remove-OktaUser -UserId $vars.user.id -Confirm:$false
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/users/$($vars.user.Id)" -and $Method -eq 'DELETE'
                }
    }
}

