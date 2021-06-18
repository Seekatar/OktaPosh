function ConvertTo-OktaAuthorizationYaml
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateScript({Test-Path $_ -PathType Container})]
        [string] $Folder
    )
    Set-StrictMode -Version Latest

  try {
      Push-Location $Folder

      if (!(Test-Path authorizationServer.json)) {
        Write-Warning "'$(Join-Path $Folder authorizationServer.json)' was not found. Use Export-OktaAuthorizationServer to populate $Folder"
        return
      }
      $auth = Get-Content authorizationServer.json -raw | ConvertFrom-Json
      $claims = ternary (Test-Path claims.json) (ConvertFrom-Json (Get-Content claims.json -raw)) $null
      $scopes = ternary (Test-Path scopes.json) (ConvertFrom-Json (Get-Content scopes.json -raw)) $null
      $policies = ternary (Test-Path policies.json) (ConvertFrom-Json (Get-Content policies.json -raw)) $null

      @"
authServer:
  name: $($auth.name)
  status: $($auth.status)
  audiences: $(($auth.audiences | Sort-Object) -join ", ")
  policies:
"@
    if ($policies) {
    foreach ($p in $policies | Where-Object system -eq $false) {
      @"
    - name: $($p.name)
      status: $($p.status)
      clients:
"@
        if ($p.conditions.clients.include -and $p.conditions.clients.include[0] -eq 'ALL_CLIENTS') {
          "        - ALL_CLIENTS"
        } else {
          foreach ($clientId in @($p.conditions.clients.include)) {
            "        - $((Get-OktaApplication -Id $clientId).label)"
          }
        }
        "      rules:"
        $rf = "rules_$($p.name).json"
        if (Test-Path $rf) {
          $rules = ConvertFrom-Json (Get-Content $rf -raw)
          Write-Verbose "Processing $rf"
          foreach ($r in $rules | Where-Object system -eq $false) {
              @"
        - name: $($r.name)
          status: $($r.status)
          conditions:
            people:
              users:
                include: $(($r.conditions.people.users.include | Sort-Object) -join ', ')
                exclude: $(($r.conditions.people.users.exclude | Sort-Object) -join ', ')
              groups:
                include: $(($r.conditions.people.groups.include | Sort-Object) -join ', ')
                exclude: $(($r.conditions.people.groups.exclude | Sort-Object) -join ', ')
              grantTypes:
                include: $(($r.conditions.grantTypes.include | Sort-Object) -join ', ')
              scopes:
                include: $(($r.conditions.scopes.include | Sort-Object) -join ', ')
          actions:
            token:
              accessTokenLifetimeMinutes: $($r.actions.token.accessTokenLifetimeMinutes)
              refreshTokenLifetimeMinutes: $($r.actions.token.refreshTokenLifetimeMinutes)
              refreshTokenWindowMinutes: $($r.actions.token.refreshTokenWindowMinutes)
"@
          }
            }
    }
    }

    "  claims:"
    foreach ($c in $claims | Where-Object valueType -ne 'SYSTEM' | Sort-Object -Property name ) {
      @"
    - name: $($c.name)
      status: $($c.status)
      claimType: $($c.claimType)
      valueType: $($c.valueType)
      value: '$($c.value)'
      conditions:
        scopes:
"@
      foreach ($s in $c.conditions.scopes | Sort-Object -Property name) {
        @"
          $s
"@
      }
  }


  "  scopes:"
    foreach ($s in $scopes | Where-Object system -eq $false | Sort-Object -Property name) {
        @"
    - name: $($s.name)
"@
  }

  } catch {
      Write-Error "Error: $_`n$($_.ScriptStackTrace)"
  } finally {
      Pop-Location
  }

}