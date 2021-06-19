Set-StrictMode -Version Latest

$script:limitThreshold = 10

function Get-OktaRateLimit {
    param ()
    return $script:rateLimit
}

function Invoke-OktaApi {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [string] $RelativeUri,
        [ValidateSet('Get', 'Head', 'Post', 'Put', 'Delete', 'Trace', 'Options', 'Merge', 'Patch')]
        [string] $Method = "Get",
        [object] $Body,
        [switch] $Json,
        [string] $OktaApiToken,
        [string] $OktaBaseUri,
        [switch] $Next,
        [switch] $NotFoundOk,
        [switch] $NoRetryOnLimit,
        [switch] $NoWarn
    )

    if ($Body -isnot [String]) {
        $Body = ConvertTo-Json $Body -Depth 10
    }

    $headers = @{
        Authorization = "SSWS $(Get-OktaApiToken $OktaApiToken)"
        Accept        = "application/json"
    }
    $baseUri = Get-OktaBaseUri $OktaBaseUri

    $objectPath = ($RelativeUri -split "\?")[0]
    if ($Next) {
        if ($script:nextUrls[$objectPath]) {
            $RelativeUri = $script:nextUrls[$objectPath]
        } else {
            if (!$NoWarn) {
                Write-Warning "Nothing available for next '$objectPath'"
            }
            return $null
        }
    }

    $params = @{
        Uri = "$baseUri/api/v1/$RelativeUri"
        ContentType = "application/json"
        Headers = $headers
        Method = $Method
    }
    if ($PSVersionTable.PSVersion.Major -ge 7) {
        $params['SkipHttpErrorCheck'] = $true
    }
    Write-Verbose "$($params.method) $($params.Uri)"

    $result = $null
    $writeMethod = $Method -in "Post", "Put", "Patch", "Merge"
    if ($writeMethod -and $body) {
        Write-Verbose "Doing $method with body $body"
        $params["Body"] = $body
    }

    if (!$writeMethod -or $PSCmdlet.ShouldProcess($RelativeUri,"Invoke API")) {
        $prevPref = $progressPreference
        $progressPreference = "silentlyContinue"
        try {
            if (!$NoRetryOnLimit) {
                $limits = Get-OktaRateLimit
                if ($limits.RateLimitRemaining -and $limits.RateLimitRemaining -lt $script:limitThreshold) {
                    $sleepMs = ($limits.RateLimitResetLocal - (Get-Date)).TotalMilliseconds
                    if ($sleepMs -gt 0) {
                        Write-Warning "Sleeping for ${sleepMs}ms since ratelimitRemaining is $($limits.RateLimitRemaining)"
                        Start-Sleep -Milliseconds $sleepMs
                    }
                }
            }
            $response = Invoke-WebRequest @params
        } catch {
            $e = $_
            # PS 5 throws on since don't have skipHttpErrorCheck
            if (!($e | Get-Member -Name Exception) -or !($e.Exception | Get-Member -Name Response)) {
                Write-Warning "Got unexpected exception"
                throw $_
            }
            $response = $e.Exception.Response
            if ($PSVersionTable.PSVersion.Major -lt 6)
            {
                $result = $_.Exception.Response.GetResponseStream()
                $reader = New-Object System.IO.StreamReader($result)
                $reader.BaseStream.Position = 0
                $reader.DiscardBufferedData()
                $Response | Add-Member -NotePropertyName Content -NotePropertyValue $reader.ReadToEnd()
            }
        } finally {
            $progressPreference = $prevPref
        }
        Test-OktaResult -Result $response -Json:$Json -Method $Method -ObjectPath $objectPath -NotFoundOk:$NotFoundOk
    }
}

function Test-OktaNext
{
    param(
        [string] $ObjectName
    )

    return [bool]$script:nextUrls[$ObjectName]
}

Register-ArgumentCompleter -CommandName "Test-OktaNext" `
        -ParameterName "ObjectName" `
        -ScriptBlock {
            (Get-OktaNextUrl).keys
        }

function Get-OktaNextUrl
{
    return $script:nextUrls
}

