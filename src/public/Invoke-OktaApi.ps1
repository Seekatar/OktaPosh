function Invoke-OktaApi {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $RelativeUri,
        [ValidateSet('Get', 'Head', 'Post', 'Put', 'Delete', 'Trace', 'Options', 'Merge', 'Patch')]
        [string] $Method = "GET",
        [string] $Body,
        [switch] $RawContent,
        [string] $OktaApiToken,
        [string] $OktaBaseUri
    )
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
    if (($Method -in "Post", "Put", "Patch", "Merge") -and $body) {
        Write-Verbose "Doing $method with body"
        $parms["Body"] = $body
    }

    if (!$body -or $PSCmdlet.ShouldProcess($RelativeUri,"Invoke API")) {
        $result = Invoke-WebRequest @parms
        Test-OktaResult -Result $result -RawContent:$RawContent
    }
}
