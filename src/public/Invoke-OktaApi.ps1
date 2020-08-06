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

    if (($Method -in "Post", "Put", "Patch", "Merge") -and $body) {
        Write-Verbose "Doing $method with body"
        Write-Verbose $body
        if ($PSCmdlet.ShouldProcess($RelativeUri,"Invoke API")) {
            $result = Invoke-WebRequest -Uri "$baseUri/api/v1/$RelativeUri" -ContentType "application/json" -Headers $headers -SkipHttpErrorCheck -Method $Method -Body $Body
        }
    }
    else {
        $result = Invoke-WebRequest -Uri "$baseUri/api/v1/$RelativeUri" -ContentType "application/json" -Headers $headers -SkipHttpErrorCheck -Method $Method
    }
    if ($result) { # WhatIf will have null $result
        Test-OktaResult -Result $result -RawContent:$RawContent
    }
}
