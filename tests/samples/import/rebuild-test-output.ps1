Push-Location (Join-Path $PSScriptRoot ..\..\samples\import\)
try {
    dir *-* | % { $file = $_; Import-OktaConfiguration -JsonConfig $_ -Variables $variables -DumpConfig | out-file "..\..\unit\export\$($file.basename)-config.json" -Encoding ascii -NoNewline }
} finally {
    Pop-Location
}