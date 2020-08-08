$script:apiToken = ""
$script:baseUri = ""

function Set-OktaOptions {
    [CmdletBinding()]
    param (
        [string] $ApiToken = $env:OktaApiToken,
        [string] $BaseUri = $env:OktaBaseUri
    )

    if (!$ApiToken -or !$BaseUri) {
        Write-Warning "Must supply ApiToken and BaseUri"
    } else {
        $script:apiToken = $ApiToken
        $script:baseUri = $baseUri
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
    } else {
        throw "Must pass in ApiToken or call Set-OktaOptions"
    }
}

function Get-OktaBaseUri {
    param (
        [string] $BaseUri
    )
    if ($BaseUri) {
        return $BaseUri
    } elseif ($script:BaseUri) {
        $script:baseUri
    } else {
        throw "Must pass in BaseUri or call Set-OktaOptions"
    }
}
