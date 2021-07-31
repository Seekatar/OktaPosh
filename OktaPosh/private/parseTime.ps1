function parseTime( $t, $now = [DateTime]::UtcNow ) {
    if ($t -match "((?<days>\d+)d){0,1}((?<hours>\d+)h){0,1}((?<minutes>\d+)m){0,1}((?<seconds>\d+)s){0,1}") {
        $ts = New-Object 'TimeSpan' -ArgumentList (ternary $matches['days'] 0),
                                                  (ternary $matches['hours'] 0),
                                                  (ternary $matches['minutes'] 0),
                                                  (ternary $matches['seconds'] 0)
        $(($now - $ts).ToString('s'))
    }
}
