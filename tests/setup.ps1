param(
    [switch] $Unit
)

Import-Module (Join-Path $PSScriptRoot ../OktaPosh/OktaPosh.psd1) -Force 3> $null

if ($Unit) {
    # Mock Invoke-OktaApi -ModuleName OktaPosh
    Mock -CommandName Invoke-WebRequest `
        -ModuleName OktaPosh `
        -MockWith {
            $Response = New-MockObject -Type Microsoft.PowerShell.Commands.WebResponseObject
            $Content = @"
{
 "errorCode": "200",
 "name":"mock",
 "system": false,
 "id": "1234",
 "access_token": "token",
 "sessionToken": "token",
 "profile":{"name": "test", "label":"test"},
 "_links": {
     "self": {
         "href" : "test/123"
     }
  }
}
"@
            $StatusCode = 200

            $Response | Add-Member -NotePropertyName Headers -NotePropertyValue @{} -Force
            if ($PSVersionTable.PSVersion.Major -ge 7) {
                $Response | Add-Member -NotePropertyName RelationLink -NotePropertyValue @{} -Force
            }
            $Response | Add-Member -NotePropertyName Content -NotePropertyValue $Content -Force
            $Response | Add-Member -NotePropertyName StatusCode -NotePropertyValue $StatusCode -Force
            $Response
        }

} else {
    if (!$env:OKTA_API_TOKEN) {
        Write-Error "Missing `$env:OKTA_API_TOKEN"
    }
    if (!$env:OKTA_BASE_URI) {
        Write-Error "Missing `$env:OKTA_BASE_URI"
    }
    if (!$env:OKTA_CLIENT_SECRET) {
        Write-Error "Missing `$env:OKTA_CLIENT_SECRET"
    }
}
# functions use the env variables by default
