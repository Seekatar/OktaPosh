# https://developer.okta.com/docs/reference/api/linked-objects

Set-StrictMode -Version Latest

function Get-OktaLink {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSShouldProcess", "")]
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory,Position=0)]
        [string] $UserId,
        [Parameter(Mandatory,Position=1)]
        [string] $LinkName,
        [switch] $GetUser,
        [switch] $Json
    )

    process {
        $result = @(Invoke-OktaApi -RelativeUri "users/$UserId/linkedObjects/$LinkName" -Method GET -Json:$Json)
        if ($result -and !$Json) {
            $result = $result | ForEach-Object { ($_._links.self.href -split '/')[-1] }
            if ($GetUser) {
                $result = $result | Get-OktaUser
            }
        }
        $result
    }
}

function Get-OktaLinkDefinition
{
    [CmdletBinding()]
    param (
        [string] $PrimaryName,
        [switch] $Json
    )

    process {
        if ($PrimaryName) {
            Invoke-OktaApi -RelativeUri "meta/schemas/user/linkedObjects/$PrimaryName" -Method GET -Json:$Json
        } else {
            Invoke-OktaApi -RelativeUri "meta/schemas/user/linkedObjects" -Method GET -Json:$Json
        }
    }
}

function New-OktaLinkDefinition {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSShouldProcess", "")]
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory,Position=0)]
        [string] $PrimaryTitle,
        [string] $PrimaryName,
        [string] $PrimaryDescription,
        [Parameter(Mandatory,Position=1)]
        [string] $AssociatedTitle,
        [string] $AssociatedName,
        [string] $AssociatedDescription
    )

    process {
        $body = [PSCustomObject]@{
            primary = @{
                name = ternary $PrimaryName $PrimaryName $PrimaryTitle.ToLower()
                title = $PrimaryTitle
                description = ternary $PrimaryDescription $PrimaryDescription "Added by OktaPosh"
                type = 'USER'
            }
            associated = @{
                name = ternary $AssociatedName $AssociatedName $AssociatedTitle.ToLower()
                title = $AssociatedTitle
                description = ternary $AssociatedDescription $AssociatedDescription "Added by OktaPosh"
                type = 'USER'
            }
        }
        Invoke-OktaApi -RelativeUri "meta/schemas/user/linkedObjects" -Body $body -Method POST
    }
}

function Remove-OktaLink {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param(
        [Parameter(Mandatory,Position=0)]
        [string] $UserId,
        [Parameter(Mandatory,Position=1)]
        [string] $PrimaryName
    )

    process {
        $user = Get-OktaUser -UserId $UserId
        if ($user) {
            $prompt = $user.profile.email
            if ($user.profile.email -ne $user.profile.login) {
                $prompt = "$($user.profile.email)/$($user.profile.login)"
            }
            if ($PSCmdlet.ShouldProcess($prompt ,"Remove $PrimaryName Link from User")) {
                Invoke-OktaApi -RelativeUri "users/$UserId/linkedObjects/$PrimaryName" -Method DELETE -NotFoundOk
            }
        }
    }
}

function Remove-OktaLinkDefinition {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param(
        [Parameter(Mandatory,ValueFromPipeline)]
        [string] $PrimaryName
    )

    process {
        Set-StrictMode -Version Latest

        if ($PSCmdlet.ShouldProcess($PrimaryName,"Remove Link Definition")) {
            Invoke-OktaApi -RelativeUri "meta/schemas/user/linkedObjects/$PrimaryName" -Method DELETE -NotFoundOk
        }
    }
}

function Set-OktaLink {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSShouldProcess", "")]
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [string] $PrimaryUserId,
        [Parameter(Mandatory)]
        [Alias('Id')]
        [string] $AssociatedUserId,
        [Parameter(Mandatory)]
        [string] $PrimaryName
    )

    process {
        Invoke-OktaApi -RelativeUri "users/$AssociatedUserId/linkedObjects/$PrimaryName/$PrimaryUserId" -Method PUT
    }
}
