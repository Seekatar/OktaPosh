<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.PARAMETER Folder
Parameter description

.EXAMPLE
dir -Directory | % { ConvertTo-AuthorizationYaml -Folder $_ | Out-file "$_/$($_.name).yaml" && "$_/$($_.name).yaml" }

Convert all the exported folders under current one to yaml

.NOTES
General notes
#>
function ConvertTo-AuthorizationYaml
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateScript({Test-Path $_ -PathType Container})]
        [string] $Folder
    )

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
  audiences: $($auth.audiences -join ", ")
  claims:
"@
    foreach ($c in $claims | Where-Object valueType -ne 'SYSTEM' | Sort-Object -Property name) {
        @"
    - name: $($c.name)
      status: $($c.status)
      claimType: $($c.claimType)
      valueType: $($c.valueType)
      value: '$($c.value)'
      conditions:
        scopes:
"@
        foreach ($s in $c.conditions.scopes) {
            @"
        $s
"@
        }
    }

    "  policies:"
    foreach ($p in $policies | Where-Object system -eq $false) {
      @"
      - name: $($p.name)
        status: $($p.status)
        priority: $($p.priority)
"@
    }

  "  scopes:"
    foreach ($s in $scopes | Where-Object system -eq $false) {
        @"
      - name: $($s.name)
"@
  }

  "  rules:"
  foreach ($rf in Get-Item rules_*.json ) {
      $rules = ConvertFrom-Json (Get-Content $rf -raw)
      Write-Verbose "Processing $rf"
      foreach ($r in $rules | Where-Object system -eq $false) {
          @"
      - name: $($r.name)
        status: $($r.status)
        conditions:
          people:
            users:
              include: $($r.conditions.people.users.include -join ', ')
              exclude: $($r.conditions.people.users.exclude -join ', ')
            groups:
              include: $($r.conditions.people.groups.include -join ', ')
              exclude: $($r.conditions.people.groups.exclude -join ', ')
            grantTypes:
              include: $($r.conditions.grantTypes.include -join ', ')
            scopes:
              include: $($r.conditions.scopes.include -join ', ')
        actions:
          token:
            accessTokenLifetimeMinutes: $($r.actions.token.accessTokenLifetimeMinutes)
            refreshTokenLifetimeMinutes: $($r.actions.token.refreshTokenLifetimeMinutes)
            refreshTokenWindowMinutes: $($r.actions.token.refreshTokenWindowMinutes)
"@
      }
  }

  } catch {
      Write-Error "Error: $_`n$($_.ScriptStackTrace)"
  } finally {
      Pop-Location
  }

}