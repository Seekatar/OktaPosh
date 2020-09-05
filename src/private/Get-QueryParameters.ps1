function Get-QueryParameters
{
    param (
        [string] $Query,
        [uint] $Limit,
        [string] $After
    )
    $parms = ""
    if ($Query)
    {
        $parms = "?q=$Query"
        if ($Limit)
        {
            $parms += "&limit=$limit"
        }
        if ($After)
        {
            $parms += "&after=$after"
        }
    }
    $parms
}