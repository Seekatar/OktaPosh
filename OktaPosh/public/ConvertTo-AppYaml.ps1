<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.PARAMETER Query
Parameter description

.EXAMPLE
$apps = Get-OktaApplication -q CCC-CA
$apps | sort -property label | ConvertTo-AppYaml | out-file applications.yaml

.NOTES
General notes
#>
function ConvertTo-AppYaml
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,ValueFromPipeline)]
        [PSCustomObject] $Application
    )

    begin {
        "applications:"
    }

    process {

        @"
  - label: $($Application.label)
    status: $($Application.status)
    name: $($Application.name)
"@
    }
}