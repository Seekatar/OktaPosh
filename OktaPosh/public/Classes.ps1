class OktaScope {
    [ValidateNotNullOrEmpty()]
    [string] $Name
    [string] $Description = "Added By OktaPOSH"
    [ValidateSet("ALL_CLIENTS","NO_CLIENTS")]
    [string] $MetadataPublish
    [bool] $IsDefault = $false
}

class OktaClaim {
    [ValidateNotNullOrEmpty()]
    [string] $Name
    [bool] $Inactive = $false
    [ValidateSet("EXPRESSION", "GROUPS")]
    [string] $ValueType
    [ValidateSet("RESOURCE", "IDENTITY", "ACCESS_TOKEN", "ID_TOKEN")] # Resource = attach to token, Identity = attach to id token
    [string] $ClaimType = "RESOURCE"
    [string] $Value
    [string[]] $Scopes
    [ValidateSet("STARTS_WITH", "EQUALS", "CONTAINS", "REGEX", "")]
    [string] $GroupFilterType
    [bool] $AlwaysIncludeInToken = $true
}

class OktaAuthorizationServer {
    [ValidateNotNullOrEmpty()]
    [string] $Name
    [string] $Description
    [string[]] $Audiences
    [OktaScope[]] $Scopes
}

class OktaGroup {
    [ValidateNotNullOrEmpty()]
    [string] $Name
    [string] $Description = "Added By OktaPOSH"
    [bool] $CreateScope = $false
}

class ServerApplication {
    [ValidateNotNullOrEmpty()]
    [string] $Name
    [bool] $Inactive = $false
    [string[]] $Scopes
    [string] $SignOnMode = "OPENID_CONNECT"
    [HashTable] $Properties
}

class SpaApplication {
    [ValidateNotNullOrEmpty()]
    [string] $Name
    [string[]] $RedirectUris
    [string] $LoginUri
    [string[]] $PostLogoutUris
    [string[]] $Origins
    [string[]] $GrantTypes
    [bool] $Inactive = $false
    [string[]] $Scopes
}

class OktaConfiguration {
    [OktaAuthorizationServer[]] $AuthorizationServers = @()
    [OktaGroup[]] $Groups = @()
    [ServerApplication[]] $ServerApplications = @()
    [SpaApplication[]] $SpaApplications = @()

    [OktaAuthorizationServer] AddAuthorizationServer() {
        $ret = [OktaAuthorizationServer]::new()
        $this.AuthorizationServers += $ret;
        return $ret
    }
}

function New-OktaConfiguration
{
[CmdletBinding()]
param()
Set-StrictMode -Version Latest
return [OktaConfiguration]::new()

}