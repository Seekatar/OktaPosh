
function ConvertTo-OktaYaml {
    param (
        [Parameter(Mandatory)]
        [string] $OutputFolder,
        [string] $AuthServerQuery,
        [string[]] $ApplicationQuery,
        [string] $OriginMatch = '.*',
        [string[]] $GroupQueries,
        [switch] $WipeFolder,
        [switch] $IncludeOkta
    )

try {
    Set-StrictMode -Version Latest
    $ErrorActionPreference = "Stop"

    if (Test-Path $OutputFolder) {
        if ($WipeFolder ) {
            Get-ChildItem $OutputFolder -Recurse | Remove-Item -ErrorAction Continue -Force -Recurse
        }
    } else {
        $null = New-Item $OutputFolder -ItemType Directory
    }

    $params = @{}
    if ($AuthServerQuery) {
        $params['q'] = $AuthServerQuery
    }
    $activity = 'Generating Yaml'
    Write-Progress -Activity $activity -Status "Processing auth servers"
    $auth = Get-OktaAuthorizationServer @params
    $auth | ForEach-Object {
        Export-OktaAuthorizationServer -AuthorizationServerId $_.id -OutputFolder "$OutputFolder\$($_.name)"
        Write-Progress -Activity $activity -Status "Processing auth servers" -CurrentOperation $_.name
    }

    Get-ChildItem $OutputFolder -Directory -Exclude '.*' | ForEach-Object { ConvertTo-OktaAuthorizationYaml $_ | Out-File (Join-Path $_ auth.yaml) }

    Write-Progress -Activity $activity -Status "Processing applications"
    $params = @{}
    Write-Warning ">>>>>>>>>>>>>>>>>>>> $ApplicationQuery"
    if ($ApplicationQuery) {
        Write-Warning ">>>>>>>>>>>>>>>>>>>> $ApplicationQuery"
        foreach ($appQuery in $ApplicationQuery) {
            $params['q'] = $appQuery
            ConvertTo-OktaApplicationYaml @params -OutputFolder "$OutputFolder" -IncludeOkta:$IncludeOkta
        }
    } else {
        ConvertTo-OktaApplicationYaml -OutputFolder "$OutputFolder"
    }

    Write-Progress -Activity $activity -Status "Processing trusted origins"
    ConvertTo-OktaTrustedOriginYaml -OriginMatch $OriginMatch | Out-File (Join-Path $OutputFolder trustedOrigins.yaml)

    Write-Progress -Activity $activity -Status "Processing groups"
    foreach ($g in $GroupQueries) {
        Write-Progress -Activity $activity -Status "Processing groups" -CurrentOperation $g
        $groups = Get-OktaGroup -q $g
        if ($groups) {
            $groups | ForEach-Object { $_.profile.name } | Sort-Object | Out-File (Join-Path $OutputFolder "groups-$g.yaml")
        }
    }

} catch {
    Write-Error "$_`n$($_.ScriptStackTrace)"
}
}