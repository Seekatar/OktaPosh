function getProp( $object, $name, $default = $null )
{
    if ($object -and (Get-Member -InputObject $object -Name $name)) {
        $object.$name
    } else {
        $default
    }
}
