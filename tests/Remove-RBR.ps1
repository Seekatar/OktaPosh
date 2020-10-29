$authServer = Get-OktaAuthorizationServer -Query 'Casualty-Reliance-RBR-AS'
$application = Get-OktaApplication -Query 'Casualty-Reliance-RBR'

Remove-OktaAuthorizationServer -AuthorizationServerId $authServer.id -Confirm:$false
Remove-OktaApplication -AppId $application.id -Confirm:$false