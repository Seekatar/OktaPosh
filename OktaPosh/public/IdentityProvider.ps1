function Get-OktaIdentityProvider
{
    [CmdletBinding(DefaultParameterSetName="Query")]
    param (
        [Parameter(Mandatory,ParameterSetName="ById",ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias("Id")]
        [string] $IdpId,
        [Parameter(ParameterSetName="Query",Position=0)]
        [string] $Query,
        [Parameter(ParameterSetName="Query")]
        [uint32] $Limit,
        [Parameter(ParameterSetName="Next")]
        [switch] $Next,
        [switch] $Json,
        [Parameter(ParameterSetName="Next")]
        [switch] $NoWarn
    )

    process {
        $IdpId = testQueryForId $GroupId $IdpId '0oa'
        if ($IdpId) {
            Invoke-OktaApi -RelativeUri "idps/$IdpId" -Json:$Json
        } else {
            Invoke-OktaApi -RelativeUri "idps$(Get-QueryParameters -Query $Query -Limit $Limit)" -Json:$Json -Next:$Next -NoWarn:$NoWarn
        }
    }
}