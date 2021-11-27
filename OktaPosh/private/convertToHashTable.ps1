function convertToHashTable( [PSCustomObject] $object ) {
    $ret = @{}
    if ($object) {
        foreach ($m in (Get-Member -InputObject $object -MemberType NoteProperty)) {
            $n = $m.Name
            $ret[$m.Name] = $object.$n
        }
    }
    $ret
}
