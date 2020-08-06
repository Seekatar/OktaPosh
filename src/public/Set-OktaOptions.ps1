$script:apiToken = "00Jy2xSscrtavh_woKo7iHrURs1M2C4tzN3_KeYQ4h"
$script:baseUri = "https://dev-671484.okta.com/"

function Set-OktaOptions {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $ApiToken,
        [Parameter(Mandatory)]
        [string] $BaseUri
    )

    $script:apiToken = $ApiToken
    $script:baseUri = $baseUri
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
