function Test-OktaResult {
    [CmdletBinding()]
    param (
        [Microsoft.PowerShell.Commands.WebResponseObject] $Result,
        [switch] $RawContent
    )
    if ( $result.StatusCode -lt 300 ) {
        if ($RawContent) {
            return $Result.Content
        } else {
            return $result.Content | ConvertFrom-Json
        }
    }
    else {
        $oktaError = $result
        try {
            $err = $result.Content | ConvertFrom-Json
            if ($err | Get-Member -Name "errorCode") {
                $oktaError = @{
                    statusCode = $result.StatusCode
                    oktaError = $err
                } | ConvertTo-Json
            }
        } catch {
            Write-Warning $_
        }
        <#
        Errors look like this https://developer.okta.com/docs/reference/error-codes/
        errorCode    : E0000011
        errorSummary : Invalid token provided
        errorLink    : E0000011
        errorId      : oaeyCzZvl2CRu6RwjpoNe_QgQ
        errorCauses  : {}
        #>
        throw $oktaError
    }
}
