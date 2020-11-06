
$script:rateLimit = [PSCustomObject]@{
    RateLimit = $null
    RateLimitRemaining = $null
    RateLimitResetUtc = $null
    RateLimitResetLocal = $null
}
$script:epochStart = New-Object DateTime -ArgumentList 1970,1,1,0,0,0,0,'Utc'
$script:nextUrls = @{}

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
        [Parameter(Mandatory)]
        [string] $ObjectPath,
        [switch] $Json
    )
    Set-RateLimit $Result

    if ( $result.StatusCode -lt 300 ) {

        # PS 7+ :( $result.RelationLink["next"]
        if ($Method -eq 'Get' -and $result.Headers["link"]) {
            Write-Verbose "Link is $($result.Headers["link"])"
            $next = $result.Headers["link"] -split ',' | Where-Object {$_ -match "<.*($ObjectPath.*)>; rel=`"next`""}
            if ($next) {
                Write-Verbose "Status: $($result.StatusCode). Setting $ObjectPath = $($Matches[1])"
                $script:nextUrls[$ObjectPath] = $Matches[1]
            } else {
                $script:nextUrls.Remove($ObjectPath)
            }
        } else {
            $script:nextUrls.Remove($ObjectPath)
        }

        if ($Json) {
            return $Result.Content
        } else {
            $parms = @{}
            if ($PSVersionTable.PSVersion.Major -ge 7) {
                $parms['Depth'] = 10
            }
            # PS v5 if don't have parens, can't use ValueFromPipeline
            # Get this error piping Get-OktaApplication | Remove-OktaApplication
            # The input object cannot be bound to any parameters for the command either because the command does not take pipeline input or the input and its properties do not match any of the parameters that take pipeline input
            return ($result.Content | ConvertFrom-Json @parms)
        }
    } elseif ($result.StatusCode -eq 404 -and $Method -eq 'GET') {
        return $null
    } else {
        # 429 is rate limit, 20-100/minute depending on the request
        # https://developer.okta.com/docs/reference/rate-limits/
        #
        Write-Verbose "StatusCode is $($result.StatusCode)"
        $oktaError = $result
        try {
            $parms = @{}
            if ($PSVersionTable.PSVersion.Major -ge 7) {
                $parms['Depth'] = 10
            }
            $err = $result.Content | ConvertFrom-Json @parms
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
