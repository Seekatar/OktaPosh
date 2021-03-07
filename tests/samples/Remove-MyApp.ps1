$authServer = Get-OktaAuthorizationServer -Query 'Casualty-Myapp-Test-AS'
$application = Get-OktaApplication -Query 'Casualty-Myapp-Test'
if ($authServer) {
    Remove-OktaAuthorizationServer -AuthorizationServerId $authServer.id -Confirm:$false
}
if ($application) {
    Remove-OktaApplication -AppId $application.id -Confirm:$false
}