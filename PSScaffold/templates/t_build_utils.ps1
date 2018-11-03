$BuildUtilsFileContent = @"
# Fill in custom build functions.

<#
.SYNOPSIS
Function to publish modules to a PowerShell Repository.

.DESCRIPTION
Function to publish PowerShell Modules to a PowerShell Repository, NuGet and SMB
supported.

.PARAMETER RepositoryName
Name of the PowerShell repository.

.PARAMETER RepositoryPath
Path to the PowerShell repository (if not PSGallery). Format: \\path\to\repo

.PARAMETER ApiKey
NuGet API key to the repository/feed.

.PARAMETER ModuleName
Name of the module to publish.

.PARAMETER ModulePath
File path to the modules manifest file (.psd1).

.PARAMETER BuildNumber
The build number of the module (minor version).

.NOTES
General notes
#>
function Publish-PSModule {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = `$true)]
        [string]
        `$RepositoryName,
        [Parameter(Mandatory = `$false)]
        [string]
        `$RepositoryPath,
        [Parameter(Mandatory = `$false)]
        `$ApiKey,
        [Parameter(Mandatory = `$true)]
        [string]
        `$ModuleName,
        [Parameter(Mandatory = `$true)]
        [string]
        `$ModulePath,
        [Parameter(Mandatory = `$true)]
        [int]
        `$BuildNumber
    )

    process {
        # Default Official PSGallery.
        `$psGalleryName = 'PSGallery'

        # Test if the repository is registered.
        Write-Verbose ("Checking if Repository: {0} is registered." -f `$RepositoryName)
        if (!(Get-PSRepository -Name `$RepositoryName -ErrorAction SilentlyContinue)) {
            # Check if the Network Path exists.
            if(!(Test-Path `$RepositoryPath)) {
                throw "The path does not exist. Please connect to the share."
            } else {
                # Register the Repository.
                if (`$RepositoryName -ne `$psGalleryName) {
                    Write-Verbose("Registering Repository: {0}." -f `$RepositoryName)
                    
                    `$registerParams = @{
                        Name = `$RepositoryName
                        SourceLocation = `$RepositoryPath
                        PublishLocation = `$RepositoryPath
                        InstallationPolicy = "Trusted"
                    }

                    Register-PSRepository @registerParams 
                }
            }
        }

        # Update existing manifest.
        Write-Verbose("Checking if Module: {0} is registered." -f `$ModuleName)
        if (Find-Module -Repository `$RepositoryName -Name `$ModuleName -ErrorAction SilentlyContinue) {
            Write-Verbose ("Updating Manifest for: {0}." -f `$ModuleName)
            `$version = (Get-Module -FullyQualifiedName `$ModulePath -ListAvailable).Version | Select-Object Major, Minor
            `$newVersion = New-Object Version -ArgumentList `$version.major, `$version.minor, `$BuildNumber
            Update-ModuleManifest -Path `$ModulePath -ModuleVersion `$newVersion
        }

        # Publish Module.
        Write-Verbose ("Publishing Module: {0}." -f `$ModuleName)

        `$publishParams = @{
            Path = ".\`$ModuleName"
        }
        # Determine type of publish.
        if (`$RepositoryName -eq `$psGalleryName) {
            if ([string]::IsNullOrEmpty(`$ApiKey)) {
                throw("Please pass on a NuGet API key to deploy to the PSGallery.")
            } else {
                `$publishParams.NuGetApiKey = `$ApiKey
            }
        } else {
            `$publishParams.Repository = `$RepositoryName
        }

        try {

            Publish-Module @publishParams

        } catch [System.Exception] {
            throw(`$_.Exception)
        }

    }
}

"@