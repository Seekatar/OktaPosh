# https://developer.okta.com/docs/reference/api/system-log
#  $_.actorDEBUG, INFO, WARN, ERROR
# -Filter 'severity eq "ERROR"'
# -Filter 'uuid eq "741dc322-cf76-11eb-899c-95a65059493b"'
function Get-OktaLog {
    [CmdletBinding(DefaultParameterSetName="Query")]
    param (
        [Parameter(ParameterSetName="Query")]
        [Alias("Q")]
        [string] $Query,
        [Parameter(ParameterSetName="Query")]
        [ValidatePattern("^\d+(h|m|s)$")]
        [string] $Since = '10m',
        [Parameter(ParameterSetName="Query")]
        [ValidateSet('DESCENDING','ASCENDING')]
        [string] $SortOrder = 'ASCENDING',
        [Parameter(ParameterSetName="Query")]
        [string] $Filter,
        [Parameter(ParameterSetName="Query")]
        [int] $Limit = 50,
        [Parameter(ParameterSetName="Query")]
        [ValidateSet('DEBUG', 'INFO', 'WARN', 'ERROR')]
        [string] $Severity,
        [switch] $Json,
        [switch] $Objects,
        [Parameter(ParameterSetName="Next")]
        [switch] $Next,
        [Parameter(ParameterSetName="Next")]
        [switch] $NoWarn
    )

    $extra = ''
    if ($Since -match "^(\d+)") {
        switch ($Since[-1]) {
            's' { $ts = [TimeSpan]::FromSeconds($matches[1]) }
            'm' { $ts = [TimeSpan]::FromMinutes($matches[1]) }
            'h' { $ts = [TimeSpan]::FromHours($matches[1]) }
            Default {
                throw "Bad Since value '$Since'"
            }
        }
        $extra = "&since=$((([DateTime]::UtcNow) - $ts).ToString('s'))Z"
    }
    if ($Severity) {
        if ($Filter) {
            $Filter = "($Filter) and severity eq `"ERROR`""
        } else {
            $Filter = "severity eq `"$Severity`""
        }
    }

    $result = @(Invoke-OktaApi -RelativeUri "logs$(Get-QueryParameters -Query $Query -Limit $Limit -SortOrder $SortOrder -Filter $Filter)$extra" -Json:$Json -Next:$Next)
    if (!$Json -and !$Objects) {
        # https://developer.okta.com/docs/reference/api/system-log/#attributes
        # only non-nullable attributes are uuid, published, eventType, version, and severity
        $result | Select-Object @{n='local time';e={$_.published.ToLocalTime()}},
                                severity,
                                @{n='actor';e={ternary $_.actor $_.actor.displayName ''}},
                                displayMessage,
                                @{n='result';e={ternary $_.outcome $_.outcome.result ''}},
                                @{n='reason';e={ternary $_.outcome $_.outcome.reason ''}},
                                @{n='id';e={$_.uuid}}


    } else {
        $result
    }

}