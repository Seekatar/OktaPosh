function New-OktaUser
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSShouldProcess", "")]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [string] $FirstName,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [string] $LastName,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [string] $Email,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $Login,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $MobilePhone,
        [Parameter(ValueFromPipelineByPropertyName)]
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
                mobilePhone = $MobilePhone
              }
        }
        Invoke-OktaApi -RelativeUri "users?activate=$(ternary $Activate 'true' 'false')" -Body $body -Method POST
    }
}

function Get-OktaUser {
    [CmdletBinding(DefaultParameterSetName="Query")]
    param (
        [Parameter(Mandatory,ParameterSetName="ById",ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias("Id")]
        [Alias("Login")]
        [string] $UserId,
        [Parameter(ParameterSetName="Query")]
        [Parameter(ParameterSetName="Search")]
        [string] $Query,
        [Parameter(ParameterSetName="Query")]
        [Parameter(ParameterSetName="Search")]
        [string] $Filter,
        [Parameter(ParameterSetName="Query")]
        [Parameter(ParameterSetName="Search")]
        [uint32] $Limit,
        [Parameter(ParameterSetName="Query")]
        [Parameter(ParameterSetName="Search")]
        [string] $After,
        [Parameter(ParameterSetName="Search")]
        [string] $Search,
        [Parameter(ParameterSetName="Search")]
        [string] $SortBy,
        [Parameter(ParameterSetName="Search")]
        [ValidateSet("asc","desc")]
        [string] $SortOrder,
        [switch] $Json
    )

    process {
        if ($UserId) {
            Invoke-OktaApi -RelativeUri "users/$UserId" -Json:$Json
        } else {
            Invoke-OktaApi -RelativeUri "users$(Get-QueryParameters `
                                 -Query $Query -Limit $Limit -After $After `
                                 -Filter $Filter `
                                 -Search $Search -SortBy $SortBy -SortOrder $SortOrder `
                                 )" -Json:$Json
        }
    }
}

function Remove-OktaUser {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param(
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias("Id")]
        [string] $UserId
    )

    process {
        Set-StrictMode -Version Latest

        $user = Get-OktaUser -UserId $UserId
        if ($user) {
            if ($PSCmdlet.ShouldProcess("'$($user.profile.email)'","Remove User")) {
                # first call DEPROVISIONS the user, second permanently deletes it
                Invoke-OktaApi -RelativeUri "users/$UserId" -Method DELETE
                Invoke-OktaApi -RelativeUri "users/$UserId" -Method DELETE
            }
        } else {
            Write-Warning "User with id '$UserId' not found"
        }

    }
}



