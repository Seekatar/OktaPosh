# https://developer.okta.com/docs/reference/api/users/

function New-OktaAuthProviderUser
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSShouldProcess", "")]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [Alias("given_name")]
        [string] $FirstName,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [Alias("family_name")]
        [string] $LastName,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [string] $Email,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $Login,
        [Parameter(Mandatory)]
        [ValidateSet('OKTA', 'ACTIVE_DIRECTORY', 'LDAP', 'FEDERATION', 'SOCIAL', 'IMPORT')]
        [string] $ProviderType,
        [string] $ProviderName,
        [string[]] $GroupIds
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
        if ($GroupIds) {
            $body['groupIds'] = @($GroupIds)
        }
        Invoke-OktaApi -RelativeUri "users?provider=true" -Body $body -Method POST
    }
}

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
        [switch] $Activate,
        [string] $Pw
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
        if ($Pw) {
            $body["credentials"] = @{
                password = @{
                    value = $Pw
             }
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
        [Parameter(ParameterSetName="Next")]
        [switch] $Next,
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
                                -Query $Query -Limit $Limit `
                                -Filter $Filter `
                                -Search $Search -SortBy $SortBy -SortOrder $SortOrder `
                                )" -Json:$Json -Next:$Next
        }
    }
}

function Get-OktaUserApplication {
    [CmdletBinding(DefaultParameterSetName="Limit")]
    param (
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias("Id")]
        [Alias("Login")]
        [string] $UserId,
        [Parameter(ParameterSetName="Limit")]
        [uint32] $Limit,
        [Parameter(ParameterSetName="Next")]
        [switch] $Next,
        [switch] $Json
    )

    process {
        $query = Get-QueryParameters -Filter "user.id eq `"$UserId`"" -Limit $Limit
        Invoke-OktaApi -RelativeUri "apps$query&expand=user%2F$UserId" -Json:$Json -Next:$Next
    }
}

function Get-OktaUserGroup {
    [CmdletBinding(DefaultParameterSetName="Limit")]
    param (
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias("Id")]
        [Alias("Login")]
        [string] $UserId,
        [Parameter(ParameterSetName="Limit")]
        [uint32] $Limit,
        [Parameter(ParameterSetName="Next")]
        [switch] $Next,
        [switch] $Json
    )

    process {
        Invoke-OktaApi -RelativeUri "users/$UserId/groups$(Get-QueryParameters -Limit $Limit)" -Json:$Json -Next:$Next
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
            if ($PSCmdlet.ShouldProcess($user.profile.email,"Remove User")) {
                # first call DEPROVISIONS the user, second permanently deletes it
                Invoke-OktaApi -RelativeUri "users/$UserId" -Method DELETE
                Invoke-OktaApi -RelativeUri "users/$UserId" -Method DELETE
            }
        } else {
            Write-Warning "User with id '$UserId' not found"
        }
    }
}
