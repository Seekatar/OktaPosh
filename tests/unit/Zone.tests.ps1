 BeforeAll {
    . (Join-Path $PSScriptRoot '../setup.ps1') -Unit
}

# Pester 5 need to pass in TestCases object to pass share
$PSDefaultParameterValues = @{
    "It:TestCases" = @{ dynamicName = "OktaPosh-test-dynamic-zone"
                        blockName = "OktaPosh-test-block-zone"
                        policyName = "OktaPosh-test-policy-zone"
                        vars = @{
                            dynamicZone = @{id = "123-123-345";name="OktaPosh-test-dynamic-zone"}
                            blockZone = @{id = "123-123-346";name="OktaPosh-test-block-zone"}
                            policyZone = @{id = "123-123-347";name="OktaPosh-test-policy-zone"}
                        }
                    }
}

Describe "Cleanup" {
    It "Remove test zone" {
    }
}

Describe "Zone" {
    It "Adds a dynamic zone" {
        $null = New-OktaDynamicZone -Name $dynamicName -Locations @(@{country='us';regions='us-en'})
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/zones" -and $Method -eq 'POST'
                }
    }
    It "Adds a block zone" {
        $null = New-OktaBlockListZone -Name $blockName -GatewayIps '192.168.1.1/24','192.168.1.22/24','192.168.1.1-192.168.1.22'
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/zones" -and $Method -eq 'POST'
                }
    }
    It "Adds a policy zone" {
        $null = New-OktaPolicyZone -Name $policyName -GatewayIps '192.168.1.1','192.168.1.22','192.168.1.1-192.168.1.22','192.168.1.1','192.168.1.22' -ProxyIps '192.168.1.1/24','192.168.1.22/24','192.168.1.1-192.168.1.22'
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/zones" -and $Method -eq 'POST'
                }
    }
    It "Gets Zones" {
        $null = @(Get-OktaZone)
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/zones" -and $Method -eq 'GET'
                }
    }
    It "Gets Zone By Usage" {
        $null = Get-OktaZone -Usage POLICY
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/zones?filter=usage+eq+`"POLICY`"" -and $Method -eq 'GET'
                }
    }
    It "Gets Zone By Id" {
        $null = Get-OktaZone -Id $vars.dynamicZone.Id
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/zones/$($vars.dynamicZone.Id)" -and $Method -eq 'GET'
                }
    }
    It "Disables Zone" {
        Disable-OktaZone -Id $vars.dynamicZone.Id -Confirm:$false
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*zones/$($vars.dynamicZone.Id)/lifecycle/deactivate" -and $Method -eq 'POST'
                }
    }
    It "Enables Zone" {
        Enable-OktaZone -Id $vars.dynamicZone.Id
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*zones/$($vars.dynamicZone.Id)/lifecycle/activate" -and $Method -eq 'POST'
                }
    }
    It "Updates Zone object" {
        # $vars.blockZone TODO what to update?
        $null = Set-OktaZone -Zone $vars.blockZone
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/zones/$($vars.blockZone.Id)" -and $Method -eq 'PUT'
                }
    }
}

Describe "Cleanup" {
    It "Remove test zone" {
        Mock Get-OktaZone -ModuleName OktaPosh -MockWith { @{name='test'}}
        Remove-OktaZone -ZoneId $vars.dynamicZone.id -Confirm:$false
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/zones/$($vars.dynamicZone.Id)" -and $Method -eq 'DELETE'
                }
        Remove-OktaZone -ZoneId $vars.blockZone.id -Confirm:$false
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/zones/$($vars.blockZone.Id)" -and $Method -eq 'DELETE'
                }
        Remove-OktaZone -ZoneId $vars.policyZone.id -Confirm:$false
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ModuleName OktaPosh `
                -ParameterFilter {
                    $Uri -like "*/zones/$($vars.policyZone.id)" -and $Method -eq 'DELETE'
                }
     }
}


