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
        [string] $ApiToken = $env:OktaApiToken,
        [string] $BaseUri = $env:OktaBaseUri
    )

    if (!$ApiToken -or !$BaseUri) {
        Write-Warning "Must supply ApiToken and BaseUri"
    } else {
        $script:apiToken = $ApiToken
        $script:baseUri = $BaseUri
        $env:OktaApiToken = $ApiToken
        $env:OktaBaseUri = $BaseUri
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
    } elseif ($env:OktaApiToken) {
        $env:OktaApiToken
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
    } elseif ($env:OktaBaseUri) {
        $env:OktaBaseUri
    } else {
        throw "Must pass in BaseUri or call Set-OktaOption"
    }
}
