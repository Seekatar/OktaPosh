$script:apiToken = ""
$script:baseUri = ""

<#
.SYNOPSIS
Set OktaOptions for accessing the API

.DESCRIPTION
Long description

.PARAMETER ApiToken
API token from Okta

.PARAMETER BaseUri
Base Okta URI for all API calls

.EXAMPLE
C:>PS Set-OktaOption -ApiToken abc123 -BaseUri https://devcccis.oktapreview.com/

.NOTES
General notes
#>
function Set-OktaOption {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
    [CmdletBinding()]
    param (
        [string] $ApiToken = $env:OKTA_API_TOKEN,
        [string] $BaseUri = $env:OKTA_BASE_URI
    )

    if (!$ApiToken -or !$BaseUri) {
        Write-Warning "Must supply ApiToken and BaseUri"
    } else {
        $script:apiToken = $ApiToken
        $script:baseUri = $BaseUri
        $env:OKTA_API_TOKEN = $ApiToken
        $env:OKTA_BASE_URI = $BaseUri
    }
}

function Get-OktaApiToken {
    param (
        [string] $ApiToken
    )
    if ($ApiToken) {
        return $ApiToken
    } elseif ($script:apiToken) {
        $script:apiToken
    } elseif ($env:OKTA_API_TOKEN) {
        $env:OKTA_API_TOKEN
    } else {
        throw "Must pass in ApiToken or call Set-OktaOption"
    }
}

function Get-OktaBaseUri {
    param (
        [string] $OktaBaseUri
    )
    if ($OktaBaseUri) {
        return $baseUri
    } elseif ($script:baseUri) {
        $script:baseUri
    } elseif ($env:OKTA_BASE_URI) {
        $env:OKTA_BASE_URI
    } else {
        throw "Must pass in BaseUri or call Set-OktaOption"
    }
}
