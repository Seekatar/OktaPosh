BeforeAll {
    . (Join-Path $PSScriptRoot '../setup.ps1') -Unit
}

# Pester 5 need to pass in TestCases object to pass share
$PSDefaultParameterValues = @{
    "It:TestCases" = @{ TrustedOriginName = "http://github.com"
                        vars = @{
                            trustedOrigin = @{id = "123-123-345";profile=@{description="test"}}
                            user = @{id = "432-675-567"}
                        }
                    }
}

Describe "trustedOrigin" {
    It "Adds a TrustedOrigin" {
        $null = New-OktatrustedOrigin -Name $trustedOriginName -Origin $trustedOriginName -CORS -Redirect
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/trustedOrigins" -and $Method -eq 'POST'
                }
    }
    It "Gets TrustedOrigins" {
        $null = @(Get-OktatrustedOrigin)
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/trustedOrigins" -and $Method -eq 'GET'
                }
    }
    It "Gets TrustedOrigin By Name" {
        $null = Get-OktatrustedOrigin -Filter "name eq `"$trustedOriginName`""
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/trustedOrigins?filter*" -and $Method -eq 'GET'
                }
    }
    It "Gets TrustedOrigin By Id" {
        $null = Get-OktatrustedOrigin -Id $vars.trustedOrigin.Id
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/trustedOrigins/$($vars.trustedOrigin.Id)" -and $Method -eq 'GET'
                }
    }
    It "Updates TrustedOrigin object" {
        $null = Set-OktatrustedOrigin -trustedOrigin ([PSCustomObject]$vars.trustedOrigin)
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/trustedOrigins/$($vars.trustedOrigin.Id)" -and $Method -eq 'PUT'
                }
    }
}

Describe "Cleanup" {
    It "Remove test TrustedOrigin" {
        Mock Get-OktatrustedOrigin -ModuleName OktaPosh -MockWith { @{name='test'}}
        Remove-OktatrustedOrigin -trustedOriginId $vars.trustedOrigin.id -Confirm:$false
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/trustedOrigins/$($vars.trustedOrigin.Id)" -and $Method -eq 'DELETE'
                }
    }
}

