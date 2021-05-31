BeforeAll {
    . (Join-Path $PSScriptRoot '../setup.ps1')
}

# Pester 5 need to pass in TestCases object to pass share
$PSDefaultParameterValues = @{
    "It:TestCases" = @{ dynamicName = "test-dynamic-zone"
                        blockName = "test-block-zone"
                        policyName = "test-policy-zone"
                        vars = @{
                            dynamicZone = @{id = $null ;name="test-dynamic-zone"}
                            blockZone = @{id = $null;name="test-block-zone"}
                            policyZone = @{id = $null;name="test-policy-zone"}
                        }
                    }
}

Describe "Cleanup" {
    It "Remove test zone" {
        Get-OktaZone | Where-Object name -like test-*-zone | Remove-OktaZone -confirm:$false
    }
}

Describe "Zone" {
    It "Adds a dynamic zone" {
        $vars.dynamicZone = New-OktaDynamicZone -Name $dynamicName -Locations @(@{country='us';regions='us-en'})
        $vars.dynamicZone.id | Should -Not -Be $null
    }
    It "Adds a block zone" {
        $vars.blockZone = New-OktaBlockListZone -Name $blockName -GatewayCIDR '192.168.1.1/24','192.168.1.22/24' -GatewayRange '192.168.1.1-192.168.1.22' -ProxyCIDR '192.168.1.1/24','192.168.1.22/24' -ProxyRange '192.168.1.1-192.168.1.22'
        $vars.blockZone.id | Should -Not -Be $null
    }
    It "Adds a policy zone" {
        $vars.policyZone = New-OktaPolicyZone -Name $policyName -GatewayCIDR '192.168.1.1/24','192.168.1.22/24' -GatewayRange '192.168.1.1-192.168.1.22' -ProxyCIDR '192.168.1.1/24','192.168.1.22/24' -ProxyRange '192.168.1.1-192.168.1.22'
        $vars.policyZone.id | Should -Not -Be $null
    }
    It "Gets Zones" {
        $zones = @(Get-OktaZone)
        $zones | Where-Object name -like test-*-zone | Should -BeGreaterOrEqual 3
    }
    It "Gets Zone By Usage" {
        $zones = Get-OktaZone -Usage POLICY
        $zones | Where-Object name -like test-policy-zone | Should -Be 1
        $zones = Get-OktaZone -Usage BLOCKLIST
        $zones | Where-Object name -like test-block-zone | Should -Be 1
    }
    It "Gets Zone By Id" {
        (Get-OktaZone -Id $vars.dynamicZone.Id).id | Should -Be $vars.dynamicZone.Id
    }
    It "Disables Zone" {
        Disable-OktaZone -Id $vars.dynamicZone.Id -Confirm:$false
        (Get-OktaZone -Id $vars.dynamicZone.Id).status | Should -Be 'DISABLED'
    }
    It "Enables Zone" {
        Enable-OktaZone -Id $vars.dynamicZone.Id
        (Get-OktaZone -Id $vars.dynamicZone.Id).status | Should -Be 'ENABLED'
    }
    It "Updates Zone object" {
        # $vars.blockZone TODO what to update?
        $null = Set-OktaZone -Zone $vars.blockZone
    }
}

Describe "Cleanup" {
    It "Remove test zone" {
        Get-OktaZone | Where-Object name -like test-*-zone | Remove-OktaZone -confirm:$false
    }
}


