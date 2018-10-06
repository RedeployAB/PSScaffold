<#
.SYNOPSIS
.DESCRIPTION
#>
function Install-PSModuleToAzVM {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [String]
        $Name,
        [Parameter(Mandatory = $true, Position = 1)]
        [String]
        $SubscriptionId,
        [Parameter(Mandatory = $true, Position = 2)]
        [String]
        $ResourceGroupName,
        [Parameter(Mandatory = $true, Position = 3)]
        [String]
        $VMName,
        [Parameter(Mandatory = $true, Position = 4)]
        [String]
        $FileName,
        [Parameter(Mandatory = $false)]
        [String]
        $Argument,
        [Parameter(Mandatory = $false, ParameterSetName = "StorageAccount")]
        [String]
        $StorageAccountName,
        [Parameter(Mandatory = $false, ParameterSetName = "StorageAccount")]
        [String]
        $Container,
        [Parameter(Mandatory = $false, ParameterSetName = "StorageAccount")]
        [String]
        $RepositoryName,
        [Parameter(Mandatory = $false, ParameterSetName = "StorageAccount")]
        [String]
        $RepositoryPath,
        [Parameter(Mandatory = $false, ParameterSetName = "StorageAccount")]
        [switch]
        $UploadScript = $false,
        [Parameter(Mandatory = $false, ParameterSetName = "FileUri")]
        [String]
        $FileUri
    )

    process {

    }
}
