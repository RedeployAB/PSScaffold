<#
.SYNOPSIS
A function to generate an install script for PowerShell modules.

.DESCRIPTION
A function to generate an install script for PowerShell modules. Assuming they 
are available to the host and in a PS Repository (NuGet Feed, Fileshare). It can also
be used to generate a template that is modified afterwards to fit other environments.

.PARAMETER RepositoryName
Name of the PSRepository that the install script should register during the install process.

.PARAMETER RepositoryPath
The network path to the PSRepository that the install script should register during the install process.

.PARAMETER Module
The name of the module. Used to generate what module to download.

.PARAMETER OutputPath
The output path of the install script. If no parameter is used it will be created in the current directory.

.PARAMETER StorageAccountName
Name of the Storage Account. Only used if the Repository is on an Azure Fileshare.

.PARAMETER StorageAccountKey
Access key to the Storage Account. Only used if the Repository is on an Azure Fileshare.

.Notes
Made as a function in a module by Karl Wallenius, Redeploy AB.
#>
function New-PSModuleInstallScript {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = "Repository")]
        [String]
        $RepositoryName,
        [Parameter(Mandatory = $true, Position = 1, ParameterSetName = "Repository")]
        [String]
        $RepositoryPath,
        [Parameter(Mandatory = $true, Position = 2)]
        [String]
        $Module,
        [Parameter(Mandatory = $false, Position = 3)]
        [String]
        $OutputPath = (Join-Path (Get-Location).Path "install-module.ps1"),
        [Parameter(Mandatory = $false, Position = 4)]
        [String]
        $StorageAccountName,
        [Parameter(Mandatory = $false, Position = 5)]
        [String]
        $StorageAccountKey
    )

    begin {
        # Validate Path given.
        if ($OutputPath.Substring(($OutputPath.Length - 1) - 3) -ne ".ps1") {
            $moduleName = $Module.ToLower()
            $OutputPath = Join-Path $OutputPath.Trim('\') "\install-$moduleName.ps1"
        }

        # Create file and path if it does not exist.
        if (!(Test-Path (Split-Path $OutputPath -Parent))) {
            New-Item -ItemType Directory -Path (Split-Path $OutputPath -Parent)
        }
    }

    process {
        # Import template.
        . "$PSScriptRoot\..\templates\script_template.ps1"

        Write-Verbose "Creating script from template."

        $scriptTemplate | Out-File -FilePath $OutputPath -Encoding utf8
    }
}
