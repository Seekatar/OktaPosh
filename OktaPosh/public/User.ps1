# https://developer.okta.com/docs/reference/api/users/

function addUser
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSShouldProcess", "")]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [HashTable] $body,
        [ValidateCount(0,20)]
        [string[]] $GroupIds,
        [switch] $Activate,
        [switch] $NextLogin,
        [string] $Provider = ""
    )

    Set-StrictMode -Version Latest
    if ($GroupIds) {
        $body['groupIds'] = @($GroupIds)
    }

    Invoke-OktaApi -RelativeUri "users?activate=$(ternary $Activate 'true' 'false')$Provider$(ternary $NextLogin '&nextLogin=changePassword' '')" `
                     -Body $body -Method POST

}

# not sure what this does
# function Convert-OktaUserToFederated {
#     [CmdletBinding(SupportsShouldProcess)]
#     param (
#         [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName,Position=0)]
#         [string] $UserId
#     )

#     process {
#         Invoke-OktaApi -RelativeUri "users/$UserId/lifecycle/reset_password?provider=FEDERATION&sendEmail=false" -Method POST
#     }
# }


function New-OktaAuthProviderUser
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSShouldProcess", "")]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory,ValueFromPipelineByPropertyName,Position=0)]
        [Alias("given_name")]
        [string] $FirstName,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName,Position=1)]
        [Alias("family_name")]
        [string] $LastName,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName,Position=2)]
        [string] $Email,
        [Parameter(ValueFromPipelineByPropertyName,Position=3)]
        [string] $Login,
        [Parameter(Mandatory,Position=4)]
        [ValidateSet('OKTA', 'ACTIVE_DIRECTORY', 'LDAP', 'FEDERATION', 'SOCIAL', 'IMPORT')]
        [string] $ProviderType,
        [string] $ProviderName,
        [ValidateCount(0,20)]
        [string[]] $GroupIds,
        [switch] $Activate
    )

    process {
        Set-StrictMode -Version Latest

        if (!$Login) {
            $Login = $Email
        }
        $body = @{
            profile = @{
                firstName = $FirstName
                lastName = $LastName
                email = $Email
                login = $Login
              }
            credentials = @{
                provider = @{
                  type = $ProviderType
                }
              }
        }
        if ($ProviderName) {
            $body.credentials.provider['name'] = $ProviderName
        }
        addUser -Body $body -GroupIds $GroupIds -Activate:$Activate -NextLogin:$false -Provider "&provider=true"
    }
}

function New-OktaUser
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSShouldProcess", "")]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory,ValueFromPipelineByPropertyName,Position=0)]
        [Alias("given_name")]
        [string] $FirstName,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [Alias("family_name")]
        [string] $LastName,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [string] $Email,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $Login,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $MobilePhone,
        [Parameter(ValueFromPipelineByPropertyName)]
        [switch] $Activate,
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateLength(1,72)]
        [string] $Pw,
        [ValidateCount(0,20)]
        [string[]] $GroupIds,
        [switch] $NextLogin,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $RecoveryQuestion,
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateLength(4,100)]
        [string] $RecoveryAnswer,
        [HashTable] $PasswordHash
    )

    begin {
        if ($NextLogin -and !$Activate) {
            throw "Must set Activate to use NextLogin"
        }
    }

    process {
        Set-StrictMode -Version Latest

        if ($Pw -and $PasswordHash) {
            throw "Can't supply both Pw and PasswordHash parameters"
        }
        if (!$Login) {
            $Login = $Email
        }
        $body = @{
            profile = @{
                firstName = $FirstName
                lastName = $LastName
                email = $Email
                login = $Login
                mobilePhone = $MobilePhone
              }
        }
        if ($Pw) {
            $body["credentials"] = @{
                password = @{
                    value = $Pw
             }
          }
        } elseif ($PasswordHash) {
            $body["credentials"] = @{
                password = $PasswordHash
            }
        }
        if ($RecoveryQuestion -and $RecoveryQuestion) {
            if (!$body["credentials"]) {
                $body["credentials"] = @{}
            } elseif ($RecoveryQuestion -and !$RecoveryQuestion -or
                      !$RecoveryQuestion -and $RecoveryQuestion) {
                throw "Must supply question and answer."
            }
            $body["credentials"]["recovery_question"] = @{
                question = $RecoveryQuestion
                answer = $RecoveryAnswer
              }
        }

        addUser -Body $body -GroupIds $GroupIds -Activate:$Activate -NextLogin:$NextLogin

        # Quirk! if don't pass in Login on a subsequent pipeline object
        # Login is set to previous value!
        $Login = $null
    }
}

function Disable-OktaUser
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSShouldProcess", "")]
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact="High")]
    param (
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName,Position=0)]
        [Alias("Id")]
        [string] $UserId,
        [switch] $SendEmail,
        [switch] $Async
    )
    process {
        $additionalHeaders = ternary $Async @{Prefer='respond-async'} $null

        if ($PSCmdlet.ShouldProcess($userId,"Deactivate User")) {
            Invoke-OktaApi -RelativeUri "users/$UserId/lifecycle/deactivate?sendEmail=$(ternary $SendEmail 'true' 'false')" -Method POST -NotFoundOk -AdditionalHeaders $additionalHeaders
        }
    }
}
<#
    for federated, users created ACTIVE

    new -> STAGED
    STAGED -> Enable -> PROVISIONED
    PROVISIONED -> user activates -> ACTIVE
    STAGED|ACTIVE -> Disable -> DEPROVISIONED
    Suspend -> SUSPENDED
    Resume -> PROVISIONED
    Can only delete if DEPROVISIONED
#>

function Enable-OktaUser
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSShouldProcess", "")]
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName,Position=0)]
        [Alias("Id")]
        [string] $UserId,
        [switch] $SendEmail
    )

    process {
        $user = Get-OktaUser -UserId $UserId
        if ($user) {
            if ($user.Status -eq 'STAGED' -or $user.Status -eq 'DEPROVISIONED' ) {
                Invoke-OktaApi -RelativeUri "users/$UserId/lifecycle/activate?sendEmail=$(ternary $SendEmail 'true' 'false')" -Method POST
            } elseif ($user.Status -eq 'PROVISIONED') {
                Invoke-OktaApi -RelativeUri "users/$UserId/lifecycle/reactivate?sendEmail=$(ternary $SendEmail 'true' 'false')" -Method POST
            } else {
                Write-Warning "User status is '$($user.Status)'. Can't enable."
            }
        } else {
            Write-Warning "UserId: '$UserId' not found"
        }
    }
}

function Suspend-OktaUser
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSShouldProcess", "")]
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName,Position=0)]
        [Alias("Id")]
        [string] $UserId,
        [switch] $CheckCurrentStatus
    )
    process {
        if ($CheckCurrentStatus) {
            $user = Get-OktaUser -UserId $UserId
            if ($user) {
                if ($user.Status -ne 'ACTIVE') {
                    Write-Warning "User status is '$($user.Status)'. Can't suspend."
                    return
                }
            } else {
                Write-Warning "UserId: '$UserId' not found"
                return
            }
        }
        Invoke-OktaApi -RelativeUri "users/$UserId/lifecycle/suspend" -Method POST
    }
}

function Resume-OktaUser
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSShouldProcess", "")]
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName,Position=0)]
        [Alias("Id")]
        [string] $UserId,
        [switch] $CheckCurrentStatus
    )

    process {
        if ($CheckCurrentStatus) {
            $user = Get-OktaUser -UserId $UserId
            if ($user) {
                if ($user.Status -ne 'SUSPENDED') {
                    Write-Warning "User status is '$($user.Status)'. Can't resume."
                    return
                }
            } else {
                Write-Warning "UserId: '$UserId' not found"
                return
            }
        }
        Invoke-OktaApi -RelativeUri "users/$UserId/lifecycle/unsuspend" -Method POST
    }
}

function Get-OktaUser {
    [CmdletBinding(DefaultParameterSetName="Query")]
    param (
        [Parameter(Mandatory,ParameterSetName="ById",ValueFromPipeline,ValueFromPipelineByPropertyName,Position=0)]
        [Alias("Id")]
        [Alias("Login")]
        [string] $UserId,
        [Parameter(ParameterSetName="Query",Position=0)]
        [Parameter(ParameterSetName="Search")]
        [string] $Query,
        [Parameter(ParameterSetName="Query")]
        [Parameter(ParameterSetName="Search")]
        [string] $Filter,
        [Parameter(ParameterSetName="Query")]
        [Parameter(ParameterSetName="Search")]
        [uint32] $Limit,
        [Parameter(ParameterSetName="Next")]
        [switch] $Next,
        [Parameter(ParameterSetName="Search")]
        [string] $Search,
        [Parameter(ParameterSetName="Search")]
        [string] $SortBy,
        [Parameter(ParameterSetName="Search")]
        [ValidateSet("asc","desc")]
        [string] $SortOrder,
        [switch] $Json,
        [Parameter(ParameterSetName="Next")]
        [switch] $NoWarn
    )

    process {
        $UserId = testQueryForId $UserId $Query '00u'
        if ($UserId) {
            Invoke-OktaApi -RelativeUri "users/$UserId" -Json:$Json
        } else {
            Invoke-OktaApi -RelativeUri "users$(Get-QueryParameters `
                                -Query $Query -Limit $Limit `
                                -Filter $Filter `
                                -Search $Search -SortBy $SortBy -SortOrder $SortOrder `
                                )" -Json:$Json -Next:$Next -NoWarn:$NoWarn
        }
    }
}

function Get-OktaUserApplication {
    [CmdletBinding(DefaultParameterSetName="Other")]
    param (
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName,Position=0)]
        [Alias("Id")]
        [Alias("Login")]
        [string] $UserId,
        [Parameter(ParameterSetName="Limit")]
        [uint32] $Limit,
        [Parameter(ParameterSetName="Next")]
        [switch] $Next,
        [switch] $Json,
        [Parameter(ParameterSetName="Next")]
        [switch] $NoWarn
    )

    process {
        $query = Get-QueryParameters -Filter "user.id eq `"$UserId`"" -Limit $Limit
        Invoke-OktaApi -RelativeUri "apps$query&expand=user%2F$UserId" -Json:$Json -Next:$Next -NoWarn:$NoWarn
    }
}

function Get-OktaUserGroup {
    [CmdletBinding(DefaultParameterSetName="Other")]
    param (
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName,Position=0)]
        [Alias("Id")]
        [Alias("Login")]
        [string] $UserId,
        [Parameter(ParameterSetName="Limit")]
        [uint32] $Limit,
        [Parameter(ParameterSetName="Next")]
        [switch] $Next,
        [switch] $Json,
        [Parameter(ParameterSetName="Next")]
        [switch] $NoWarn
    )

    process {
        Invoke-OktaApi -RelativeUri "users/$UserId/groups$(Get-QueryParameters -Limit $Limit)" -Json:$Json -Next:$Next -NoWarn:$NoWarn
    }
}

function Remove-OktaUser {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param(
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName,Position=0)]
        [Alias("Id")]
        [string] $UserId,
        [switch] $Async
    )

    process {
        Set-StrictMode -Version Latest

        $additionalHeaders = ternary $Async @{Prefer='respond-async'} $null

        $user = Get-OktaUser -UserId $UserId
        if ($user) {
            $prompt = $user.profile.email
            if ($user.profile.email -ne $user.profile.login) {
                $prompt = "$($user.profile.email)/$($user.profile.login)"
            }
            if ($PSCmdlet.ShouldProcess($prompt,"Remove User")) {
                if ($user.Status -ne 'DEPROVISIONED') {
                    $null = Disable-OktaUser -UserId $UserId -Confirm:$false
                }
                Invoke-OktaApi -RelativeUri "users/$UserId" -Method DELETE -AdditionalHeaders $additionalHeaders
            }
        } else {
            Write-Warning "User with id '$UserId' not found"
        }
    }
}
function Remove-OktaUserSession {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param(
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName,Position=0)]
        [Alias("Id")]
        [string] $UserId,
        [switch] $RevokeOauthTokens
    )

    process {
        if ($PSCmdlet.ShouldProcess($UserId,"Remove User sessions")) {
            Invoke-OktaApi -RelativeUri "users/$UserId/sessions?oauthTokens=$(ternary $RevokeOauthTokens 'true' 'false')" -Method DELETE
        }
    }
}
function Reset-OktaUserMfa {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName,Position=0)]
        [Alias("Id")]
        [string] $UserId
    )

    process {
        Set-StrictMode -Version Latest

        Invoke-OktaApi -RelativeUri "users/$UserId/lifecycle/reset_factors" -Method POST
    }
}

function Reset-OktaPassword {
    [CmdletBinding(SupportsShouldProcess,DefaultParameterSetName="Reset")]
    param(
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName,Position=0)]
        [Alias("Id")]
        [string] $UserId,
        [switch] $SendEmail
    )

    process {
        Set-StrictMode -Version Latest

        # Seems can't use forgot_password getting this message, even though user is ACTIVE
        # --- Forgot password is not allowed in the user's current status
        # if ($UseRecoveryQuestion) {
        #     Invoke-OktaApi -RelativeUri "users/$UserId/credentials/forgot_password?sendEmail=$(ternary $SendEmail 'true' 'false')" -Method POST
        # }
        Invoke-OktaApi -RelativeUri "users/$UserId/lifecycle/reset_password?sendEmail=$(ternary $SendEmail 'true' 'false')" -Method POST
    }
}

function Reset-OktaPasswordWithAnswer {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName,Position=0)]
        [Alias("Id")]
        [string] $UserId,
        [Parameter(Mandatory,Position=1)]
        [ValidateLength(4,100)]
        [string] $Answer,
        [Parameter(Mandatory,Position=2)]
        [ValidateLength(1,72)]
        [string] $Pw
    )

    process {
        Set-StrictMode -Version Latest

        $body = @{ password = @{ value = $Pw }; recovery_question = @{ answer = $Answer }}
        Invoke-OktaApi -RelativeUri "users/$UserId/credentials/forgot_password" -Method POST -Body $body
    }
}

function Revoke-OktaPassword {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName,Position=0)]
        [Alias("Id")]
        [string] $UserId,
        [switch] $TempPw
    )

    process {
        Invoke-OktaApi -RelativeUri "users/$UserId/lifecycle/expire_password?tempPassword=$(ternary $TempPw 'true' 'false')" -Method POST
    }
}

function Set-OktaPassword {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName,Position=0)]
        [Alias("Id")]
        [string] $UserId,
        [Parameter(Mandatory,Position=1)]
        [string] $OldPw,
        [Parameter(Mandatory,Position=2)]
        [ValidateLength(1,72)]
        [string] $NewPw,
        [switch] $Strict
    )

    process {
        $body = @{
            oldPassword = @{ value = $OldPw }
            newPassword = @{ value = $NewPw }
        }
        Invoke-OktaApi -RelativeUri "users/$UserId/credentials/change_password?strict=$(ternary $Strict 'true' 'false')" -Method POST -Body $body
    }
}
function Set-OktaUserRecoveryQuestion {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName,Position=0)]
        [Alias("Id")]
        [string] $UserId,
        [Parameter(Mandatory,Position=1)]
        [ValidateLength(1,72)]
        [string] $Pw,
        [Parameter(Mandatory,Position=2)]
        [ValidateLength(1,100)]
        [string] $Question,
        [Parameter(Mandatory,Position=3)]
        [ValidateLength(4,100)]
        [string] $Answer
    )

    process {
        Set-StrictMode -Version Latest
        $body = @{
            password = @{ value = $Pw}
            recovery_question = @{ question = $Question; answer = $Answer }
        }
        Invoke-OktaApi -RelativeUri "users/$UserId/credentials/change_recovery_question" -Method POST -Body $body
    }
}

function Set-OktaUser {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory,Position=0,ValueFromPipeline)]
        [PSCustomObject]$User
    )

    process {
        if ($PSCmdlet.ShouldProcess($User.id,"Update User")) {
            Invoke-OktaApi -RelativeUri "users/$($User.id)" -Method PUT -Body (ConvertTo-Json $User -Depth 10)
        }
    }
}

function Unlock-OktaUser
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSShouldProcess", "")]
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName,Position=0)]
        [Alias("Id")]
        [string] $UserId,
        [switch] $CheckCurrentStatus
    )

    process {
        if ($CheckCurrentStatus) {
            $user = Get-OktaUser -UserId $UserId
            if ($user) {
                if ($user.Status -ne 'LOCKED_OUT') {
                    Write-Warning "User status is '$($user.Status)'. Can't unlock."
                    return
                }
            } else {
                Write-Warning "UserId: '$UserId' not found"
                return
            }
        }
        Invoke-OktaApi -RelativeUri "users/$UserId/lifecycle/unlock" -Method Post
    }
}
