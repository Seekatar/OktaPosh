# propfile properties supported by
# App
# AppUser
# User
# AppGroupAssignment
function Add-PropertiesToObject {
    param (
        [Parameter(Mandatory)]
        [PSCustomObject] $Object,
        [hashtable] $Properties
    )

    if ($Properties) {
        if (!(Get-Member -InputObject $Object -Name 'profile')) {
            Add-Member -InputObject $Object -MemberType NoteProperty -Name 'profile' -Value $Properties
        }
        else {
            foreach ($p in $Properties.Keys) {
                if (!(Get-Member -InputObject $Object.profile -Name $p)) {
                    Add-Member -InputObject $Object.profile -MemberType NoteProperty -Name $p -Value $Properties[$p]
                } else {
                    $Object.profile.$p = $Properties[$p]
                }
            }
        }
    }
}

