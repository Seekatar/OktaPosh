# https://developer.okta.com/docs/reference/api/policy

function Get-OktaPolicy {
    param (
        [Parameter(Mandatory,ParameterSetName="ById",ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias("Id")]
        [string] $PolicyId,
        [Parameter(ParameterSetName="ById")]
        [switch] $WithRules, # returns max 20, if > 20 an error
        [Parameter(Mandatory,ParameterSetName="ByType")]
        [ValidateSet('OKTA_SIGN_ON', 'PASSWORD', 'MFA_ENROLL', 'OAUTH_AUTHORIZATION_POLICY', 'IDP_DISCOVERY','USER_LIFECYCLE')]
        [string] $Type,
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
    param (
        [Parameter(Mandatory,ParameterSetName="ById",ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias("Id")]
        [string] $PolicyId
    )
    process {
        Invoke-OktaApi -RelativeUri "policies/$PolicyId/lifecycle/deactivate"
    }
}

function Enable-OktaPolicy {
    param (
        [Parameter(Mandatory,ParameterSetName="ById",ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias("Id")]
        [string] $PolicyId
    )
    process {
        Invoke-OktaApi -RelativeUri "policies/$PolicyId/lifecycle/activate"
    }
}

function New-OktaPolicyTask {
    param (
        [Parameter(Mandatory)]
        [string] $PolicyId,
        [Parameter(Mandatory)]
        [System.DateTimeOffset] $DateTime,
        [Parameter(Mandatory)]
        [ValidateSet('Daily','Once')]
        [string] $Frequency
    )
    [string] $Type = 'SCHEDULED'
    [string] $Status = 'ACTIVE'
    $task = @{
        action = @{
            type = 'EXECUTE_POLICY'
            policy = @{
                id = $PolicyId
            }
        }
        schedule = @{}
        type = $Type
        status = $Status
    }
    if ($Frequency -eq 'Daily') {
        $task.schedule = @{
            cron = @{
                expression = "$min $hr * * *"
            }
        }
    } else {
        $task.schedule = @{
            runOnce = @{
                runTime = "$($DateTime.ToUniversalTime().ToString('s'))$($DateTime.ToString('%K'))"
            }
        }
    }

    Invoke-OktaApi -RelativeUri 'tasks' -Method Post -Body $task
}
function Remove-OktaPolicyTask {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param(
    [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
    [Alias('Id')]
    [string] $PolicyId
    )

    begin {
        $tasks = Get-OktaTask
    }

    process {
        $task = @($tasks | Where-Object { $_.action.type -eq 'EXECUTE_POLICY' -and $_.action.policy.id -eq $PolicyId })
        foreach ($task in $tasks ) {
            Remove-OktaTask -TaskId $task.id
        }
    }
}

function Remove-OktaTask {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param(
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias('Id')]
        [string] $TaskId
    )

    process {
        Set-StrictMode -Version Latest

        $Task = Get-OktaTask -TaskId $TaskId
        if ($Task) {
            if ($PSCmdlet.ShouldProcess($TaskId,"Remove Task")) {
                Invoke-OktaApi -RelativeUri "tasks/$TaskId" -Method DELETE
            }
        } else {
            Write-Warning "Task with id '$TaskId' not found"
        }
    }
}

function New-OktaAutomation {
    param (
        [string] $Name,
        [ValidateSet('InactiveUser','PasswordWillExpireIn')]
        [string] $Type,
        [System.DateTimeOffset] $DateTime,
        [ValidateSet('Daily','Once')]
        [string] $Frequency,
        [int] $Days,
        [ValidateSet('SUSPENDED','INACTIVE','DELETED')]
        [string] $ChangeTo,
        [string[]] $GroupIds,
        [switch] $Activate,
        [int] $Priority = 2
    )

    $automationPolicy = @{
        status = ternary $Activate 'ACTIVE' 'INACTIVE'
        name = $Name
        priority = $Priority
        conditions = @{
            people = @{
                users = @{}
            }
            groups = @{
                include = $GroupIds
            }
        }
    }
    if ($Type -eq 'PasswordWillExpireIn') {
        $automationPolicy.conditions.people.users = @{
            passwordExpiration = @{
                unit = "DAYS"
                number = $Days
            }
        }
    } else {
        $automationPolicy.conditions.people.users = @{
            inactivity = @{
                unit = "DAYS"
                number = $Days
            }
        }
    }
    $policy = Invoke-OktaApi -RelativeUri 'policies' -Method POST -Body $automationPolicy
    if ($policy -and $policy.id) {
        New-OktaPolicyTask -PolicyId $policy.id -DateTime $DateTime -Frequency $Frequency
    }
    $policy
}

function New-OktaPolicyRule {
    param (
        [Parameter(Mandatory)]
        [string] $PolicyId,
        [Parameter(Mandatory)]
        [ValidateSet('SIGN_ON','PASSWORD','MFA_ENROLL','USER_LIFECYCLE')]
        [string] $Type,
        [Parameter(Mandatory)]
        [string] $Name,
        [switch] $Activate,
        [int] $Priority = 2
    )

    Set-StrictMode -Version Latest

    $policyRule = @{
        name = $Name
        system = $false
        type = $Type
        conditions = $null
        status = (ternary $Activate 'ACTIVE' 'INACTIVE')
        priority = $Priority
        actions = @{
            updateUserLifecycle= @{
                targetStatus = "INACTIVE"
                quietPeriod = @{
                    number =  0
                    unit = "DAYS"
                }
            }
        }
    }
    Invoke-OktaApi -RelativeUri "policies/$policyId/rules" -Method POST -Body $policyRule
}

function Remove-OktaPolicy {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param(
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias('Id')]
        [string] $PolicyId
    )

    process {
        Set-StrictMode -Version Latest

        $Policy = Get-OktaPolicy -PolicyId $PolicyId
        if ($Policy) {
            if ($PSCmdlet.ShouldProcess($Policy.name,"Remove Policy")) {
                Invoke-OktaApi -RelativeUri "policies/$PolicyId" -Method DELETE
            }
        } else {
            Write-Warning "Policy with id '$PolicyId' not found"
        }
    }
}

