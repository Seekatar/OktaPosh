<#
.SYNOPSIS
Get an Okta JWT token

.DESCRIPTION
This only does the client credentials flow

.PARAMETER ClientId
ClientId from the Application

.PARAMETER OktaTokenUrl
Url to get the token, e.g. "https://dev-671484.okta.com/oauth2/default/v1/token"

.PARAMETER ClientSecret
Client secret for the Application

.PARAMETER SecureClientSecret
Client secret for the Application as a SecureString

.EXAMPLE
$env:OktaClientSecret="..."
Get-OktaJwt -ClientId "0oap78eubPKbQCnEk4x6" -OktaTokenUrl "https://dev-671484.okta.com/oauth2/ausp6jwjzhUYrGJsG4x6/v1/token"

.OUTPUTS
JWT string or null
#>
function Get-OktaJwt {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [string] $ClientId = $env:OktaClientId,

        [string] $OktaTokenUrl = $env:OktaTokenUrl,

        [Parameter(ParameterSetName="Clear")]
        [string] $ClientSecret = $env:OktaClientSecret,

        [Parameter(Mandatory,ParameterSetName="Secure")]
        [securestring] $SecureClientSecret
    )

    $ErrorActionPreference = "Stop"

    if ((!$ClientSecret -and !$SecureClientSecret) -or !$OktaTokenUrl -or !$ClientId) {
        throw "Must pass in ClientSecret or SecureClientSecure and ClientId and OktaTokenUrl, or set environment variables"
    }

    if ($SecureClientSecret) {
        # (from VSTeam)
        # Convert the securestring to a normal string
        # this was the one technique that worked on Mac, Linux and Windows
        $credential = New-Object System.Management.Automation.PSCredential $account, $SecurePersonalAccessToken
        $secret = $credential.GetNetworkCredential().Password
    } else {
        $secret = $ClientSecret
    }

    $clientCreds = [System.Text.Encoding]::UTF8.GetBytes("${ClientId}:$secret");

    $oktaHeader = @{ Authorization = "Basic $([System.Convert]::ToBase64String($clientCreds))"
                    Accept = "application/json" }

    $body = "grant_type=client_credentials&scope=get_item%20access_token%20save_item" # space-separated scopes

    $parms = @{}
    if ($PSVersionTable.PSVersion.Major -ge 7) {
        $parms['SkipHttpErrorCheck'] = $true
    }
    $jwt = ""
    $result = Invoke-WebRequest $env:okta_url -Method Post -Body $body -ContentType "application/x-www-form-urlencoded" -Headers $oktaHeader @parms
    if ($result.StatusCode -ne 200)
    {
        Write-Warning "Couldn't get JWT"
        $result
    }
    else
    {
        $jwt = (ConvertFrom-Json $result.Content).access_token
    }
    $jwt

}