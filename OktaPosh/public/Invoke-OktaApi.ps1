Set-StrictMode -Version Latest

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
        [switch] $Next
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
            Write-Warning "Nothing available for next '$objectPath'"
            return $null
        }
    }

    $parms = @{
        Uri = "$baseUri/api/v1/$RelativeUri"
        ContentType = "application/json"
        Headers = $headers
        Method = $Method
    }
    if ($PSVersionTable.PSVersion.Major -ge 7) {
        $parms['SkipHttpErrorCheck'] = $true
    }
    Write-Verbose "$($parms.method) $($parms.Uri)"

    $result = $null
    $writeMethod = $Method -in "Post", "Put", "Patch", "Merge"
    if ($writeMethod -and $body) {
        Write-Verbose "Doing $method with body $body"
        $parms["Body"] = $body
    }

    if (!$writeMethod -or $PSCmdlet.ShouldProcess($RelativeUri,"Invoke API")) {
        $prevPref = $progressPreference
        $progressPreference = "silentlyContinue"
        try {
            $response = Invoke-WebRequest @parms
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
        Test-OktaResult -Result $response -Json:$Json -Method $Method -ObjectPath $objectPath
    }
}

function Test-OktaNext
{
    param(
        [ValidateSet('groups','users','apps','authorizationServers')]
        [string] $ObjectName
    )

    return [bool]$script:nextUrls[$ObjectName]
}

function Get-OktaNextUrl
{
    return $script:nextUrls
}

