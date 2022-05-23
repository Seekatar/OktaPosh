BeforeAll {
    . (Join-Path $PSScriptRoot '../setup.ps1')
}

# Pester 5 need to pass in TestCases object to pass share
$PSDefaultParameterValues = @{
    "It:TestCases" = @{vars = @{
            groupId = ''
            appId   = ''
        }
    }
}

Describe "Cleanup" {
    It "Remove test user app and group" {
        Get-OktaGroup -Search 'profile.name eq "OktaPosh-test-user-import"' | Remove-OktaGroup -Confirm:$false
        Get-OktaApp -q 'OktaPosh-test-user-import' | Remove-OktaApp -Confirm:$false
        Get-OktaUser -search 'profile.login sw "okta-test-"' | Remove-OktaUser -Confirm:$false
    }
    It "Add test app and group" {
        Import-OktaConfiguration -JsonConfig (Join-Path $PSScriptRoot '../samples/import/user-import-app.json')
        $vars.groupId = (Get-OktaGroup -Search 'profile.name eq "OktaPosh-test-user-import"').Id
        $vars.appId = (Get-OktaApp -q 'OktaPosh-test-user-import').Id
        $vars.groupId | Should -Not -BeNullOrEmpty
        $vars.appId | Should -Not -BeNullOrEmpty
    }
}

Describe "UserImport" {
    It "Adds two users with clear text passwords" {
        Import-OktaUser -Path (Join-Path $PSScriptRoot 'user-import/clear-text.csv') -HashAlgorithm ClearText -Limit 2

        # added with no pw, so PROVISIONED
        $user = Get-OktaUser -Login 'okta-test-gvance'
        $user | Should -Not -BeNull
        $user.status | Should -Be 'PROVISIONED'

        # added with pw, so ACTIVE
        $user = Get-OktaUser -Login 'okta-test-abutler'
        $user | Should -Not -BeNull
        $user.status | Should -Be 'ACTIVE'
    }

    It "Adds two users to app" {
        Import-OktaUser -Path (Join-Path $PSScriptRoot 'user-import/clear-text.csv') -HashAlgorithm ClearText -Skip 2 -Limit 2

        $user = Get-OktaUser -Login 'okta-test-wcornish'
        $user | Should -Not -BeNull
        $user.status | Should -Be 'ACTIVE'
        $g = Get-OktaUserGroup -UserId $user.Id | Where-Object id -eq $vars.groupId
        $g | Should -Not -BeNull
        $a = Get-OktaUserApp -UserId $user.Id | Where-Object id -eq $vars.appId
        $a | Should -Not -BeNull

        $user = Get-OktaUser -Login 'okta-test-gknox'
        $user | Should -Not -BeNull
        $user.status | Should -Be 'ACTIVE'
        Get-OktaUserGroup -UserId $user.Id | Where-Object id -eq $vars.groupId | Should -Not -BeNull
        Get-OktaUserApp -UserId $user.Id | Where-Object id -eq $vars.appId | Should -Not -BeNull
    }
}

Describe "Cleanup" {
    It "Remove test user app and group" {
        Get-OktaGroup -q 'OktaPosh-test-user-import' | Remove-OktaGroup -Confirm:$false
        Get-OktaApp -q 'OktaPosh-test-user-import' | Remove-OktaApp -Confirm:$false
        Get-OktaUser -search 'profile.login sw "okta-test-"' | Remove-OktaUser -Confirm:$false
    }
}

