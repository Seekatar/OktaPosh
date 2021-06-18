#  $_.actorDEBUG, INFO, WARN, ERROR
# -Filter 'severity eq "ERROR"'
function Get-OktaLog {
    [CmdletBinding(DefaultParameterSetName="Query")]
    param (
        [Parameter(ParameterSetName="Query")]
        [Alias("Q")]
        [string] $Query,
        [Parameter(ParameterSetName="Query")]
        [ValidatePattern("^\d+(h|m|s)$")]
        [string] $Since,
        [Parameter(ParameterSetName="Query")]
        [ValidateSet('DESCENDING','ASCENDING')]
        [string] $SortOrder = 'ASCENDING',
        [Parameter(ParameterSetName="Query")]
        [string] $Filter,
        [Parameter(ParameterSetName="Query")]
        [int] $Limit = 50,
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
                throw "Back Since value"
            }
        }
        $extra = "&since=$(((Get-Date -AsUTC) - $ts).ToString('s'))Z"
    }

    $result = @(Invoke-OktaApi -RelativeUri "logs$(Get-QueryParameters -Query $Query -Limit $Limit -SortOrder $SortOrder -Filter $Filter)$extra" -Json:$Json -Next:$Next)
    if (!$Json -and !$Objects) {
        $result | Select-Object @{n='local time';e={$_.published.ToLocalTime()}}, severity, @{n='actor';e={ternary $_.actor $_.actor.displayName ''}}, displayMessage
    } else {
        $result
    }

}