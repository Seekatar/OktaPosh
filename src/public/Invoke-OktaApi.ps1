function Invoke-OktaApi {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $RelativeUri,
        [ValidateSet('Get', 'Head', 'Post', 'Put', 'Delete', 'Trace', 'Options', 'Merge', 'Patch')]
        [string] $Method = "GET",
        [object] $Body,
        [switch] $RawContent,
        [string] $OktaApiToken,
        [string] $OktaBaseUri,
        [switch] $BodyIsString
    )
    if ($Body -is [String] -and !$BodyIsString) {
        $Body = ConvertTo-Json $Body -Depth 10
    }

    $headers = @{
        Authorization = "SSWS $(Get-OktaApiToken $OktaApiToken)"
        Accept        = "application/json"
    }
    $baseUri = Get-OktaBaseUri $OktaBaseUri

    $parms = @{
        Uri = "$baseUri/api/v1/$RelativeUri"
        ContentType = "application/json"
        Headers = $headers
        Method = $Method
    }
    if ($PSVersionTable.PSVersion.Major -ge 7) {
        $parms['SkipHttpErrorCheck'] = $true
    }
    $result = $null
    $writeMethod = $Method -in "Post", "Put", "Patch", "Merge"
    if ($writeMethod -and $body) {
        Write-Verbose "Doing $method with body"
        $parms["Body"] = $body
    }

    if (!$writeMethod -or $PSCmdlet.ShouldProcess($RelativeUri,"Invoke API")) {
        $result = Invoke-WebRequest @parms
        Test-OktaResult -Result $result -RawContent:$RawContent
    }
}
