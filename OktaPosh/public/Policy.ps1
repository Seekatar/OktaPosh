# https://developer.okta.com/docs/reference/api/policy
Set-StrictMode -Version Latest

function Get-OktaPasswordPolicy {
    [CmdletBinding(DefaultParameterSetName="ByType")]
    param (
        [Parameter(Mandatory,ParameterSetName="ById",ValueFromPipeline,ValueFromPipelineByPropertyName,Position=0)]
        [Alias("Id")]
        [string] $PolicyId,
        [Parameter(ParameterSetName="ById")]
        [switch] $WithRules, # returns max 20, if > 20 an error
        [Parameter(ParameterSetName="ByType")]
        [ValidateSet('OKTA_SIGN_ON', 'PASSWORD', 'MFA_ENROLL', 'OAUTH_AUTHORIZATION_POLICY', 'IDP_DISCOVERY','USER_LIFECYCLE')]
        [string] $Type = 'PASSWORD',
        [switch] $JSON
    )

    process {
        if ($PolicyId) {
            $uri = "policies/$PolicyId"
            if ($WithRules) {
                $uri += '?expand=rules'
            }
            Invoke-OktaApi -RelativeUri $uri -Json:$JSON
        } else {
            Invoke-OktaApi -RelativeUri "policies?type=$Type" -Json:$JSON
        }
    }
}

function Disable-OktaPolicy {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias("Id")]
        [string] $PolicyId
    )
    process {
        Invoke-OktaApi -RelativeUri "policies/$PolicyId/lifecycle/deactivate" -Method POST
    }
}
if (!(Test-Path alias:Disable-OktaPasswordPolicy)) {
    New-Alias -Name Disable-OktaPasswordPolicy -Value Disable-OktaPolicy
}

function Disable-OktaPolicyRule {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $PolicyId,
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias('Id')]
        [string] $RuleId
    )
    process {
        Invoke-OktaApi -RelativeUri "policies/$PolicyId/rules/$RuleId/lifecycle/deactivate" -Method POST
    }
}
if (!(Test-Path alias:Disable-OktaPasswordPolicyRule)) {
    New-Alias -Name Disable-OktaPasswordPolicyRule -Value Disable-OktaPolicyRule
}

function Enable-OktaPolicy {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,ParameterSetName="ById",ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias("Id")]
        [string] $PolicyId
    )
    process {
        Invoke-OktaApi -RelativeUri "policies/$PolicyId/lifecycle/activate" -Method POST
    }
}
if (!(Test-Path alias:Enable-OktaPasswordPolicy)) {
    New-Alias -Name Enable-OktaPasswordPolicy -Value Enable-OktaPolicy
}

function Enable-OktaPolicyRule {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $PolicyId,
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias("Id")]
        [string] $RuleId
    )
    process {
        Invoke-OktaApi -RelativeUri "policies/$PolicyId/rules/$RuleId/lifecycle/activate" -Method POST
    }
}
if (!(Test-Path alias:Enable-OktaPasswordPolicyRule)) {
    New-Alias -Name Enable-OktaPasswordPolicyRule -Value Enable-OktaPolicyRule
}

function New-OktaPasswordPolicy {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [string] $Name,
        [string] $Description,
        [switch] $Inactive,
        [int] $Priority = 1,
        [int] $MinLength = 8,
        [int] $MinLowerCase = 1,
        [int] $MinUpperCase = 1,
        [int] $MinNumber = 1,
        [int] $MinSymbol = 0,
        [int] $MaxAgeDays = 60,
        [int] $ExpireWarnDays = 0,
        [int] $MinAgeMinutes = 0,
        [int] $HistoryCount = 5,
        [int] $MaxAttempts = 3,
        [int] $AutoUnlockMinutes = 5,
        [switch] $ExcludeUserName,
        [switch] $ExcludeDictionaryCommon,
        [string[]] $ExcludeAttributes = @(),
        [string[]] $IncludeGroups = @(),
        [ValidateSet("ACTIVE","INACTIVE")]
        [string] $RecoveryQuestionStatus = "ACTIVE",
        [ValidateSet("OKTA","Active Directory")]
        [string] $Provider = "OKTA"
    )
    Set-StrictMode -Version Latest

    $body = @{
        status = ternary $Inactive "INACTIVE" "ACTIVE"
        name = $Name
        description = ternary $Description $Description "Added by OktaPosh"
        priority = $Priority
        system = $false
        conditions = @{
            people = @{
                groups = @{
                    include = $IncludeGroups
                }
            }
            authProvider = @{
                provider = $Provider
            }
        }
        settings = @{
            password = @{
                complexity = @{
                    minLength = $MinLength
                    minLowerCase = $MinLowerCase
                    minUpperCase = $MinUpperCase
                    minNumber = $MinNumber
                    minSymbol = $MinSymbol
                    excludeUsername = [bool]$ExcludeUserName
                    dictionary = @{
                        common = @{
                            exclude = [bool]$ExcludeDictionaryCommon
                        }
                    }
                    excludeAttributes = $ExcludeAttributes
                }
                age = @{
                    maxAgeDays = $MaxAgeDays
                    expireWarnDays = $ExpireWarnDays
                    minAgeMinutes = $MinAgeMinutes
                    historyCount = $HistoryCount
                }
                lockout = @{
                    maxAttempts = $MaxAttempts
                    autoUnlockMinutes = $AutoUnlockMinutes
                    userLockoutNotificationChannels = @()
                    showLockoutFailures = $false
                }
            }
            recovery = @{
                factors = @{
                    recovery_question = @{
                        status = $RecoveryQuestionStatus
                        properties = @{
                            complexity = @{
                                minLength = 4
                            }
                        }
                    }
                    okta_email = @{
                        status = "ACTIVE"
                        properties = @{
                            recoveryToken = @{
                                tokenLifetimeMinutes = 60
                            }
                        }
                    }
                    okta_sms = @{
                        status = "INACTIVE"
                    }
                    okta_call = @{
                        status = "INACTIVE"
                    }
                }
            }
            delegation = @{
                options = @{
                    skipUnlock = $false
                }
            }
        }
        type = "PASSWORD"
    }

    if ($PSCmdlet.ShouldProcess($Name, "Add new Policy")) {
        Invoke-OktaApi -RelativeUri "policies" -Method POST -Body $body
    }
}

function New-OktaPasswordPolicyRule {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [string] $PolicyId,
        [Parameter(Mandatory)]
        [string] $Name,
        [switch] $AllowPasswordChange,
        [switch] $AllowSelfServicePasswordReset,
        [switch] $AllowSelfServiceUnlock,
        [switch] $Inactive,
        [int] $Priority = 1
    )

    $body = @{
        status = ternary $Inactive "INACTIVE" "ACTIVE"
        name = $Name
        priority = $Priority
        system = $false
        conditions = @{
            people = @{
                users = @{
                    exclude = @()
                }
            }
            network = @{
                connection = "ANYWHERE"
            }
        }
        actions = @{
            passwordChange = @{
                access = ternary $AllowPasswordChange "ALLOW" "DENY"
            }
            selfServicePasswordReset = @{
                access = ternary $AllowSelfServicePasswordReset "ALLOW" "DENY"
            }
            selfServiceUnlock = @{
                access = ternary $AllowSelfServiceUnlock "ALLOW" "DENY"
            }
        }
        type = "PASSWORD"
    }

    if ($PSCmdlet.ShouldProcess("${PolicyId}:$Name", "Add new Policy Rule")) {
        Invoke-OktaApi -RelativeUri "policies/$PolicyId/rules" -Method POST -Body $body
    }

}

function Get-OktaPolicyRule {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,Position=0)]
        [string] $PolicyId,
        [Alias('Id')]
        [string] $RuleId,
        [switch] $JSON
    )

    $RuleId = testQueryForId $RuleId $Query '0pr'
    if ($RuleId) {
        Invoke-OktaApi -RelativeUri "policies/$PolicyId/rules/$RuleId" -Json:$JSON
    } else {
        Invoke-OktaApi -RelativeUri "policies/$PolicyId/rules" -Json:$JSON
    }
}
if (!(Test-Path alias:Get-OktaPasswordPolicyRule)) {
    New-Alias -Name Get-OktaPasswordPolicyRule -Value Get-OktaPolicyRule
}

# function New-OktaPolicyTask {
    # [CmdletBinding()]
#     param (
#         [Parameter(Mandatory)]
#         [string] $PolicyId,
#         [Parameter(Mandatory)]
#         [System.DateTimeOffset] $DateTime,
#         [Parameter(Mandatory)]
#         [ValidateSet('Daily','Once')]
#         [string] $Frequency
#     )
#     [string] $Type = 'SCHEDULED'
#     [string] $Status = 'ACTIVE'
#     $task = @{
#         action = @{
#             type = 'EXECUTE_POLICY'
#             policy = @{
#                 id = $PolicyId
#             }
#         }
#         schedule = @{}
#         type = $Type
#         status = $Status
#     }
#     if ($Frequency -eq 'Daily') {
#         $task.schedule = @{
#             cron = @{
#                 expression = "$min $hr * * *"
#             }
#         }
#     } else {
#         $task.schedule = @{
#             runOnce = @{
#                 runTime = "$($DateTime.ToUniversalTime().ToString('s'))$($DateTime.ToString('%K'))"
#             }
#         }
#     }

#     Invoke-OktaApi -RelativeUri 'tasks' -Method Post -Body $task
# }
# function Remove-OktaPolicyTask {
#     [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
#     param(
#     [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
#     [Alias('Id')]
#     [string] $PolicyId
#     )

#     begin {
#         $tasks = Get-OktaTask
#     }

#     process {
#         $task = @($tasks | Where-Object { $_.action.type -eq 'EXECUTE_POLICY' -and $_.action.policy.id -eq $PolicyId })
#         foreach ($task in $tasks ) {
#             Remove-OktaTask -TaskId $task.id
#         }
#     }
# }

# function Remove-OktaTask {
#     [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
#     param(
#         [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
#         [Alias('Id')]
#         [string] $TaskId
#     )

#     process {
#         Set-StrictMode -Version Latest

#         $Task = Get-OktaTask -TaskId $TaskId
#         if ($Task) {
#             if ($PSCmdlet.ShouldProcess($TaskId,"Remove Task")) {
#                 Invoke-OktaApi -RelativeUri "tasks/$TaskId" -Method DELETE
#             }
#         } else {
#             Write-Warning "Task with id '$TaskId' not found"
#         }
#     }
# }

# function New-OktaAutomation {
    # [CmdletBinding()]
#     param (
#         [string] $Name,
#         [ValidateSet('InactiveUser','PasswordWillExpireIn')]
#         [string] $Type,
#         [System.DateTimeOffset] $DateTime,
#         [ValidateSet('Daily','Once')]
#         [string] $Frequency,
#         [int] $Days,
#         [ValidateSet('SUSPENDED','INACTIVE','DELETED')]
#         [string] $ChangeTo,
#         [string[]] $GroupIds,
#         [switch] $Activate,
#         [int] $Priority = 2
#     )

#     $automationPolicy = @{
#         status = ternary $Activate 'ACTIVE' 'INACTIVE'
#         name = $Name
#         priority = $Priority
#         conditions = @{
#             people = @{
#                 users = @{}
#             }
#             groups = @{
#                 include = $GroupIds
#             }
#         }
#     }
#     if ($Type -eq 'PasswordWillExpireIn') {
#         $automationPolicy.conditions.people.users = @{
#             passwordExpiration = @{
#                 unit = "DAYS"
#                 number = $Days
#             }
#         }
#     } else {
#         $automationPolicy.conditions.people.users = @{
#             inactivity = @{
#                 unit = "DAYS"
#                 number = $Days
#             }
#         }
#     }
#     $policy = Invoke-OktaApi -RelativeUri 'policies' -Method POST -Body $automationPolicy
#     if ($policy -and $policy.id) {
#         New-OktaPolicyTask -PolicyId $policy.id -DateTime $DateTime -Frequency $Frequency
#     }
#     $policy
# }

# function New-OktaPolicyRule {
    # [CmdletBinding()]
#     param (
#         [Parameter(Mandatory)]
#         [string] $PolicyId,
#         [Parameter(Mandatory)]
#         [ValidateSet('SIGN_ON','PASSWORD','MFA_ENROLL','USER_LIFECYCLE')]
#         [string] $Type,
#         [Parameter(Mandatory)]
#         [string] $Name,
#         [switch] $Activate,
#         [int] $Priority = 2
#     )

#     Set-StrictMode -Version Latest

#     $policyRule = @{
#         name = $Name
#         system = $false
#         type = $Type
#         conditions = $null
#         status = (ternary $Activate 'ACTIVE' 'INACTIVE')
#         priority = $Priority
#         actions = @{
#             updateUserLifecycle= @{
#                 targetStatus = "INACTIVE"
#                 quietPeriod = @{
#                     number =  0
#                     unit = "DAYS"
#                 }
#             }
#         }
#     }
#     Invoke-OktaApi -RelativeUri "policies/$policyId/rules" -Method POST -Body $policyRule
# }

function Set-OktaPasswordPolicy {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory,Position=0)]
        [PSCustomObject] $Policy
    )

    if ($PSCmdlet.ShouldProcess($Policy.name, "Update Policy")) {
        Invoke-OktaApi -RelativeUri "policies/$($Policy.Id)" -Method PUT -Body $Policy
    }

}
function Remove-OktaPasswordPolicy {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param(
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias('Id')]
        [string] $PolicyId
    )

    process {
        Set-StrictMode -Version Latest

        $Policy = Get-OktaPasswordPolicy -PolicyId $PolicyId
        if ($Policy) {
            if ($PSCmdlet.ShouldProcess($Policy.name, "Remove Policy")) {
                Invoke-OktaApi -RelativeUri "policies/$PolicyId" -Method DELETE
            }
        } else {
            Write-Warning "Policy with id '$PolicyId' not found"
        }
    }
}

function Remove-OktaPolicyRule {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param(
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [string] $PolicyId,
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias('Id')]
        [string] $RuleId
    )

    process {
        Set-StrictMode -Version Latest

        $Rule = Get-OktaPolicyRule -PolicyId $PolicyId -RuleId $RuleId
        if ($Rule) {
            if ($PSCmdlet.ShouldProcess($Rule.name, "Remove Policy Rule")) {
                Invoke-OktaApi -RelativeUri "policies/$PolicyId/rules/$RuleId" -Method DELETE
            }
        } else {
            Write-Warning "Policy rule for policy with id '$PolicyId' and id '$RuleId' not found"
        }
    }
}
if (!(Test-Path alias:Remove-OktaPasswordPolicyRule)) {
    New-Alias -Name Remove-OktaPasswordPolicyRule -Value Remove-OktaPolicyRule
}

