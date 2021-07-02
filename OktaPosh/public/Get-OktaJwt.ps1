Set-StrictMode -Version Latest

function Get-OktaJwt {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [string] $ClientId = $env:OKTA_CLIENT_ID,

        [string] $Issuer = $env:OKTA_ISSUER,

        [string] $RedirectUri = $env:OKTA_REDIRECT_URI,

        [string] $Username = $env:OKTA_USERNAME,

        [Alias("Pw")]
        [string] $ClientSecret = $env:OKTA_CLIENT_SECRET,

        [Alias("Password")]
        [securestring] $SecureClientSecret,

        [switch] $IdToken,

        [Parameter(Mandatory)]
        [string[]] $Scopes
    )

    $ErrorActionPreference = "Stop"
    if ($PSVersionTable.PSVersion.Major -lt 7) {
        Write-Warning "Currently this only works on PS 7 or higher"
        return
    }

    if ((!$ClientSecret -and !$SecureClientSecret) -or !$Issuer -or !$ClientId -or !$Username -or !$RedirectUri) {
        Write-Warning @"
Missing a parameter:
  Have Username: $([bool]$Username)
  Have Secret: $($ClientSecret -or $SecureClientSecret)
  Have Issuer: $([bool]$Issuer)
  Have ClientId: $([bool]$ClientId)
  Have RedirectUrl: $(!$Username -or $RedirectUri)
"@
        throw "Missing required parameter. See help."
    }
    if (!$RedirectUri.EndsWith("/")) {
        $RedirectUri = $RedirectUri + "/"
    }

    if ($SecureClientSecret) {
        # (from VSTeam)
        # Convert the securestring to a normal string
        # this was the one technique that worked on Mac, Linux and Windows
        $credential = New-Object System.Management.Automation.PSCredential "ClientSecret", $SecureClientSecret
        $secret = $credential.GetNetworkCredential().Password
    } else {
        $secret = $ClientSecret
    }

    # Code derived from https://devforum.okta.com/t/unit-testing-and-implicit-flow/1210/4
    $body = @{
        username = $Username
        password = $secret
        options  = @{
            multiOptionalFactorEnroll = $true
            warnBeforePasswordExpired = $true
        }
    }

    $uri = New-Object 'System.Uri' -ArgumentList $Issuer
    $baseUri = New-Object 'System.Uri' -ArgumentList $uri.GetLeftPart("Authority")
    $sessionUri = New-Object 'System.Uri' -ArgumentList $baseUri, "api/v1/authn"
    $prevPref = $progressPreference
    $progressPreference = "silentlyContinue"
    try {
        $trans = Invoke-WebRequest -Uri $sessionUri -Method Post `
                        -Headers @{ 'Accept'            = 'application/json'
                                    'Content-Type'      = 'application/json'
                                } `
                        -Body (ConvertTo-Json $body) `
                        -MaximumRedirection 0
        $params = @{}
        if ($PSVersionTable.PSVersion.Major -ge 7) {
            $params['Depth'] = 10
        }
        $session = $trans.Content | ConvertFrom-Json @params
    } catch {
        $e = $_
        try {
            if ($_.Exception.Response.StatusCode -eq 'Unauthorized') {
                Write-Warning "Unauthorized response. Probably bad userName or password"
                return
            } else {
                throw $e
            }
        } catch {
            throw $e
        }
    } finally {
        $progressPreference = $prevPref
    }

    if (!$session) {
        Write-Warning "Didn't get session"
        return
    }
    $progressPreference = "silentlyContinue"
    try {
        $tokenUri = New-Object 'System.Uri' -ArgumentList $uri,($uri.PathAndQuery+"/v1/authorize?" +
                                                "response_type=$(ternary $IdToken 'id_token' 'token')&" +
                                                "scope=$($scopes -join '%20')&" +
                                                'state=TEST&' +
                                                'nonce=TEST&' +
                                                "client_id=$ClientId&" +
                                                "redirect_uri=$redirectUri&" +
                                                "sessionToken=$($session.sessionToken)")
        Write-Verbose "Token uri is $tokenUri"
        $null = Invoke-WebRequest $tokenUri -MaximumRedirection 2
    }
    catch {
        # expect 302 response
        Write-Verbose "Exception Type: $($_.GetType())"
        Write-Verbose "Exception & Stack: $_`n$($_.ScriptStackTrace)"

        $e = $_
        if (!($e | Get-Member -Name Exception) -or !($e.Exception | Get-Member -Name Response)) {
            Write-Warning "Got unexpected exception (expected 302)"
            throw $_
        }

        if ($e.Exception.Response.StatusCode -eq "Redirect") { #302
            Write-Verbose $e.Exception.Response.Headers.Location
            $q = [System.Web.HttpUtility]::ParseQueryString($e.Exception.Response.Headers.Location)
            Write-Verbose "Headers are: $($e.Exception.Response.Headers)"
            Write-Verbose "Headers.Location is: $($e.Exception.Response.Headers.Location)"
            if ($IdToken)
            {
                $token = $q["$redirectUri#id_token"]
            }
            else
            {
                $token = $q["$redirectUri#access_token"]
            }
            if (!$token) {
                Write-Warning "Didn't get token for $redirectUri and IdToken = $([bool]$IdToken)"
                foreach ($k in $q.AllKeys) {
                    Write-Warning " q[$k] = $($q[$k])"
                }
            }
            $token
        } else {
            Write-Warning "Didn't get redirect for JWT"
            Write-Warning $_
        }
    } finally {
        $progressPreference = $prevPref
    }
}

function Get-OktaAppJwt {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [string] $ClientId = $env:OKTA_CLIENT_ID,

        [string] $Issuer = $env:OKTA_ISSUER,

        [Alias("Pw")]
        [string] $ClientSecret = $env:OKTA_CLIENT_SECRET,

        [Alias("Password")]
        [securestring] $SecureClientSecret,

        [Parameter(Mandatory)]
        [string[]] $Scopes
    )

    $ErrorActionPreference = "Stop"

    $GrantType = "client_credentials"

    if ((!$ClientSecret -and !$SecureClientSecret) -or !$Issuer -or !$ClientId) {
        Write-Warning @"
Missing a parameter:
  Have Secret: $($ClientSecret -or $SecureClientSecret)
  Have Issuer: $([bool]$Issuer)
  Have ClientId: $([bool]$ClientId)
"@
        throw "Missing required parameter. See help."
    }

    if ($SecureClientSecret) {
        # (from VSTeam)
        # Convert the securestring to a normal string
        # this was the one technique that worked on Mac, Linux and Windows
        $credential = New-Object System.Management.Automation.PSCredential "ClientSecret", $SecureClientSecret
        $secret = $credential.GetNetworkCredential().Password
    } else {
        $secret = $ClientSecret
    }

    $clientCreds = [System.Text.Encoding]::UTF8.GetBytes("${ClientId}:$secret");

    $oktaHeader = @{ Authorization = "Basic $([System.Convert]::ToBase64String($clientCreds))"
                    Accept = "application/json" }

    $body = "grant_type=$GrantType&scope=$($Scopes -join '%20')" # space-separated scopes

    $params = @{}
    if ($PSVersionTable.PSVersion.Major -ge 7) {
        $params['SkipHttpErrorCheck'] = $true
    }
    $jwt = ""
    Write-Verbose $body
    if (!($Issuer.EndsWith("/v1/token"))) {
        $Issuer = $Issuer + "/v1/token"
    }
    $prevPref = $progressPreference
    $progressPreference = "silentlyContinue"
    try {
        $result = Invoke-WebRequest $Issuer -Method Post -Body $body -ContentType "application/x-www-form-urlencoded" -Headers $oktaHeader @params
        if ($result.StatusCode -ne 200)
        {
            Write-Warning "Couldn't get JWT"
            Write-Warning $result
        }
        else
        {
            $params = @{}
            if ($PSVersionTable.PSVersion.Major -ge 7) {
                $params['Depth'] = 5
            }
            $jwt = (ConvertFrom-Json $result.Content @params).access_token
        }
        $jwt
    } finally {
        $progressPreference = $prevPref
    }
}