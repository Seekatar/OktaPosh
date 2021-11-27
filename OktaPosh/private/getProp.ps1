function getProp( $object, $name, $default = $null )
{
    if (Get-Member -InputObject $object -Name $name) {
        $object.$name
    } else {
        $default
    }
}
