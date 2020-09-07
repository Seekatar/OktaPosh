function Add-PropertiesToApp {
    param (
        [Parameter(Mandatory)]
        [PSCustomObject] $Application,
        [hashtable] $Properties
    )

    if ($Properties) {
        if (!(Get-Member -InputObject $Application -Name 'profile')) {
            Add-Member -InputObject $Application -MemberType NoteProperty -Name 'profile' -Value $Properties
        }
        else {
            foreach ($p in $Properties.Keys) {
                if (!(Get-Member -InputObject $Application.profile -Name $p)) {
                    Add-Member -InputObject $Application.profile -MemberType NoteProperty -Name $p -Value $Properties[$p]
                } else {
                    $Application.profile.$p = $Properties[$p]
                }
            }
        }
    }
}

