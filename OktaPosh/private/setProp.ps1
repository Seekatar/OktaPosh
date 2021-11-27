function setProp($object, $name, $value)
{
    if (!(Get-Member -InputObject $object -Name $name) ) {
        Add-Member -InputObject $object -Value $value -Name $name -MemberType NoteProperty
    } else {
        $object.$name = $value
    }
}

