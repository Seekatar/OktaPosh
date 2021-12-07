Set-StrictMode -Version Latest

$script:apiToken = ""
$script:baseUri = ""
$script:warnIfMore = $false

function Set-OktaOption {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
    [CmdletBinding()]
    param (
        [string] $ApiToken = $env:OKTA_API_TOKEN,
        [string] $BaseUri = $env:OKTA_BASE_URI,
        [bool] $UseQueryForId = $true,
        [switch] $WarnIfMore
    )


    if (!$ApiToken -or !$BaseUri) {
        Write-Warning "Must supply ApiToken and BaseUri"
        $false
    } else {
        $script:useQueryForId = $UseQueryForId
        $script:apiToken = $ApiToken
        $script:baseUri = $BaseUri
        $script:warnIfMore = [bool]$WarnIfMore
        $env:OKTA_API_TOKEN = $ApiToken
        $env:OKTA_BASE_URI = $BaseUri
        $true
    }
}

function Get-OktaReadOnly {
    $script:readOnly
}

function Set-OktaReadOnly {
    param (
        [bool] $ReadOnly = $true
    )
    $script:readOnly = $ReadOnly
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
        return $OktaBaseUri
    } elseif ($script:baseUri) {
        $script:baseUri
    } elseif ($env:OKTA_BASE_URI) {
        $env:OKTA_BASE_URI
    } else {
        throw "Must pass in BaseUri or call Set-OktaOption"
    }
}

function Get-OktaQueryForId {
    $script:useQueryForId
}
