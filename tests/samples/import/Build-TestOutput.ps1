Push-Location (Join-Path $PSScriptRoot ..\..\samples\import\)
$variables = @{
    cluster = "OktaPosh"
    domainSuffix = "-dev"
    additionalRedirect = "http://localhost:8009/my-ui/implicit/callback"
    groupNames = "groupNames.json"
    groupObjects = "groups.json"
}
try {
    Get-ChildItem *-*.json |
        ForEach-Object {
            $file = $_
            "Doing file $file"
            Import-OktaConfiguration -JsonConfig $file -Variables $variables -DumpConfig |
                out-file "..\..\unit\export\$($file.basename).json" -Encoding ascii -NoNewline }
} finally {
    Pop-Location
}