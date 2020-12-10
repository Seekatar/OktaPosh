BeforeAll {
    . (Join-Path $PSScriptRoot '../setup.ps1') -Unit
}

Describe "Test RateLimit" {
    It 'Tests RateLimit hit' {
        $limits = Get-OktaRateLimit
        $limits.RateLimitRemaining = 1
        $limits.RateLimitResetLocal = (Get-Date) + [Timespan]::FromSeconds(5)
        $elapse = Measure-Command { Get-OktaApplication -Limit 1 }
        $elapse.TotalSeconds | Should -BeGreaterThan 3
    }
}