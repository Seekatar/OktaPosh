#  https://developer.okta.com/docs/reference/api/schemas/#app-user-profile-custom-subschema
function Get-OktaApplicationSchema
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias("Id")]
        [string] $AppId,
        [switch] $Json
    )

    process
    {
        Set-StrictMode -Version Latest
        Invoke-OktaApi -RelativeUri "meta/schemas/apps/$AppId/default" -Method GET -Json:$Json
    }
}

# TODO Array support
function Set-OktaApplicationSchemaProperty
{
    [OutputType([PSCustomObject])]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [Alias("Id")]
        [string] $AppId,
        [Parameter(Mandatory)]
        [string] $Name,
        [string] $Description,
        [ValidateSet("string", "boolean", "number", "integer")]
        [string] $Type = "string",
        [switch] $Required,
        [switch] $UserScope,
        [int] $Min,
        [int] $Max,
        [switch] $Json
    )

    Set-StrictMode -Version Latest

    if ($PSCmdlet.ShouldProcess("$AppId", "Add property to Application"))
    {
        $body = @{
            definitions = @{
                custom = @{
                    id         = "#custom"
                    type       = "object"
                    properties = @{
                        "$name" = @{
                            title       = $name
                            description = ternary $Description $Description "Added by OktaPosh"
                            type        = $type
                            required    = [bool]$Required
                            scope       = ternary $UserScope "SELF" "NONE"
                        }
                    }
                }
            }
        }
        if ($Type -eq "string" -and $null -ne $Min -and $null -ne $Max)
        {
            $body.definitions.custom.properties[$name]["minLength"] = $Min
            $body.definitions.custom.properties[$name]["maxLength"] = $Max
        }
        elseif (($Type -eq "number" -or $Type -eq "integer") -and ($null -ne $Min -and $null -ne $Max))
        {
            $body.definitions.custom.properties[$name]["minimum"] = $Min
            $body.definitions.custom.properties[$name]["maximum"] = $Max
        }

        Invoke-OktaApi -RelativeUri "meta/schemas/apps/$AppId/default" -Method POST -Body $body -Json:$Json
    }
}

function Remove-OktaApplicationSchemaProperty
{
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param(
        [Parameter(Mandatory)]
        [Alias("Id")]
        [string] $AppId,
        [Parameter(Mandatory)]
        [string] $Name,
        [switch] $Json
    )

    Set-StrictMode -Version Latest

    if ($PSCmdlet.ShouldProcess("$AppId", "Add property to Application"))
    {
        $body = @{
            definitions = @{
                custom = @{
                    id         = "#custom"
                    type       = "object"
                    properties = @{
                        "$name" = $null
                    }
                }
            }
        }

        Invoke-OktaApi -RelativeUri "meta/schemas/apps/$AppId/default" -Method POST -Body $body -Json:$Json
    }
}
