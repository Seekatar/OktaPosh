
function ConvertTo-OktaYaml {
    param (
        [Parameter(Mandatory)]
        [string] $Folder,
        [string] $AuthServerQuery,
        [string] $ApplicationQuery,
        [string] $OriginMask = '*',
        [switch] $WipeFolder
    )
try {
    Set-StrictMode -Version Latest

    if ((Test-Path $Folder) -and $WipeFolder ) {
        Get-ChildItem $Folder -Recurse | Remove-Item -ErrorAction Continue -Force -Recurse
    }

    $params = @{}
    if ($AuthServerQuery) {
        $params['q'] = $AuthServerQuery
    }
    Write-Host "-- Processing auth servers"
    $auth = Get-OktaAuthorizationServer @params
    $auth | ForEach-Object { Export-OktaAuthorizationServer -AuthorizationServerId $_.id -OutputFolder "$folder\$($_.name)" }

    Get-ChildItem $folder -Directory | ForEach-Object { ConvertTo-OktaAuthorizationYaml $_ | Out-File (Join-Path $_ auth.yaml) }

    $params = @{}
    if ($ApplicationQuery) {
        $params['q'] = $ApplicationQuery
    }
    Write-Host "-- Processing applications"

    ConvertTo-OktaApplicationYaml @params -OutputFolder "$folder"

    $params = @{}
    if ($ApplicationQuery) {
        $params['q'] = $ApplicationQuery
    }

    Write-Host "-- Processing trusted origins"
    ConvertTo-OktaTrustedOriginYaml -Mask $OriginMask | Out-File (Join-Path $folder trustedOrigins.yaml)
} catch {
    Write-Error "$_`n$($_.ScriptStackTrace)"
}
}