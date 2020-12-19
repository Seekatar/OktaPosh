$authServer = Get-OktaAuthorizationServer -Query 'Casualty-Myapp-Test-AS'
$application = Get-OktaApplication -Query 'Casualty-Myapp-Test'

Remove-OktaAuthorizationServer -AuthorizationServerId $authServer.id -Confirm:$false
Remove-OktaApplication -AppId $application.id -Confirm:$false