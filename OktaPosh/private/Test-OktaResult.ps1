
$script:rateLimit = [PSCustomObject]@{
    RateLimit = $null
    RateLimitRemaining = $null
    RateLimitResetUtc = $null
    RateLimitResetLocal = $null
}
$script:epochStart = New-Object DateTime -ArgumentList 1970,1,1,0,0,0,0,'Utc'

function Set-RateLimit {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
    [CmdletBinding()]
    param (
        [Microsoft.PowerShell.Commands.WebResponseObject] $Result
    )

    if ($Result.Headers['X-Rate-Limit-Limit']) {
        $script:rateLimit.RateLimit = [int]($Result.Headers['X-Rate-Limit-Limit'] | Select-Object -First 1 )
    } else {
        $script:rateLimit.RateLimit = $null
    }
    if ($Result.Headers['X-Rate-Limit-Remaining']) {
        $script:rateLimit.RateLimitRemaining = [int]($Result.Headers['X-Rate-Limit-Remaining'] | Select-Object -First 1 )
    } else {
        $script:rateLimit.RateLimitRemaining = $null
    }
    if ($Result.Headers['X-Rate-Limit-Reset']) {
        $script:rateLimit.RateLimitResetUtc = $script:epochStart.AddSeconds([int]($Result.Headers['X-Rate-Limit-Reset'] | Select-Object -First 1 ))
        $script:rateLimit.RateLimitResetLocal = $script:rateLimit.RateLimitResetUtc.ToLocalTime()
    } else {
        $script:rateLimit.RateLimitResetUtc = $null
        $script:rateLimit.RateLimitResetLocal = $null
    }
    Write-Verbose $script:rateLimit
}

function Test-OktaResult {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [Microsoft.PowerShell.Commands.WebResponseObject] $Result,
        [Parameter(Mandatory)]
        [string] $Method,
        [switch] $Json
    )
    Set-RateLimit $Result

    if ( $result.StatusCode -lt 300 ) {
        if ($Json) {
            return $Result.Content
        } else {
            return $result.Content | ConvertFrom-Json -Depth 10
        }
    } elseif ($result.StatusCode -eq 404 -and $Method -eq 'GET') {
        return $null
    } else {
        # 429 is rate limit, 20-100/minute depending on the request
        # https://developer.okta.com/docs/reference/rate-limits/
        $oktaError = $result
        try {
            $err = $result.Content | ConvertFrom-Json -Depth 10
            if ($err | Get-Member -Name "errorCode") {
                $oktaError = @{
                    statusCode = $result.StatusCode
                    oktaError = $err
                } | ConvertTo-Json -Depth 10
            }
        } catch {
            Write-Warning $_
        }
        <#
        Errors look like this https://developer.okta.com/docs/reference/error-codes/
        errorCode    : E0000011
        errorSummary : Invalid token provided
        errorLink    : E0000011
        errorId      : oaeyCzZvl2CRu6RwjpoNe_QgQ
        errorCauses  : {}
        #>
        throw $oktaError
    }
}
