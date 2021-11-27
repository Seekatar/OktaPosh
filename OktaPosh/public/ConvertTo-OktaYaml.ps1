
function ConvertTo-OktaYaml {
    param (
        [Parameter(Mandatory)]
        [string] $OutputFolder,
        [string] $AuthServerQuery,
        [string] $ApplicationQuery,
        [string] $OriginLike = '*',
        [string[]] $GroupQueries,
        [switch] $WipeFolder
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

    Get-ChildItem $OutputFolder -Directory | ForEach-Object { ConvertTo-OktaAuthorizationYaml $_ | Out-File (Join-Path $_ auth.yaml) }

    $params = @{}
    if ($ApplicationQuery) {
        $params['q'] = $ApplicationQuery
    }
    Write-Progress -Activity $activity -Status "Processing applications"

    ConvertTo-OktaApplicationYaml @params -OutputFolder "$OutputFolder"

    Write-Progress -Activity $activity -Status "Processing trusted origins"
    ConvertTo-OktaTrustedOriginYaml -OriginLike $OriginLike | Out-File (Join-Path $OutputFolder trustedOrigins.yaml)

    Write-Progress -Activity $activity -Status "Processing groups"
    foreach ($g in $GroupQueries) {
        Write-Progress -Activity $activity -Status "Processing groups" -CurrentOperation $g
        $groups = Get-OktaGroup -q $g
        if ($groups) {
            $groups | ForEach-Object { $_.profile.name } | Sort-Object | Out-File (Join-Path $OutputFolder "groups-$g.yaml")
        }
    }
    Write-Progress -Activity $activity -Status "Processing trusted origins"
    ConvertTo-OktaTrustedOriginYaml -OriginLike $OriginLike | Out-File (Join-Path $OutputFolder trustedOrigins.yaml)

} catch {
    Write-Error "$_`n$($_.ScriptStackTrace)"
}
}