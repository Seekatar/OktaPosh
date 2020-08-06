# https://developer.okta.com/docs/reference/api/apps/#application-properties

function Get-OktaApplication {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $AppId,
        [switch] $RawContent
    )

    Invoke-OktaApi -RelativeUri "apps/$AppId" -RawContent:$RawContent
}
function Find-OktaApplication {
    [CmdletBinding()]
    param (
        [string] $Query,
        [uint] $Limit,
        [string] $After
    )

    Invoke-OktaApi -RelativeUri "apps$(Get-QueryParameters $Query $Limit $After)"
}

<#
.SYNOPSIS
Set an application property

.DESCRIPTION
This will set a property on the application that can be used in a Claim with an Expression of app.profile.<name>

.PARAMETER App
Application object retrieved from Get-OktaApplication

.PARAMETER Properties
Hashtable of properties and the values to set on the Application

.EXAMPLE
$app = Get-OktaApplcation $appId
Set-OktaApplicationProperty -Application $app -Properties @{client_id = "INS1", client_profile_id = 1234 }

Set client_id and client_profile_id on the app

.NOTES
General notes
#>
function Set-OktaApplicationProperty {
    [CmdletBinding()]
    param (
        [PSCustomObject] $App,
        [hashtable] $Properties
    )

    if (!(Get-Member -InputObject $App -Name 'profile')) {
        Add-Member -InputObject $App -MemberType NoteProperty -Name 'profile' -Value $Properties
    }
    else {
        foreach ($p in $Properties.Keys) {
            if (!(Get-Member -InputObject $App.profile -Name $p)) {
                Add-Member -InputObject $App.profile -MemberType NoteProperty -Name $p -Value $Properties[$p]
            } else {
                $App.profile.$p = $Properties[$p]
            }
        }
    }

    Invoke-OktaApi -RelativeUri "apps/$($App.Id)" -Method PUT -Body (ConvertTo-Json $app -Depth 10)
}

