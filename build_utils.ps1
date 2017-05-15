<#
.SYNOPSIS
    Publishe a PowerShell to a PSRepository.
.DESCRIPTION
    This function publishes a module to a PSRepository. It checks the current version on the destination
    repository and compares it with the build number. It updates the Module Manifest at publishing.
.NOTES
    Written by Michael Willis xainey@github - https://github.com/xainey.
    Reworked by Karl Wallenius, KarlGW@github - https://github.com/KarlGW

    Supports PSGallery as well after update.
#>
function Publish-PSModule {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]
        $RepositoryName,
        [Parameter(Mandatory=$false)]
        [string]
        $RepositoryPath,
        [Parameter(Mandatory=$true)]
        [string]
        $ModuleName,
        [Parameter(Mandatory=$true)]
        [string]
        $ModulePath,
        [Parameter(Mandatory=$false)]
        $ApiKey,
        [Parameter(Mandatory=$true)]
        [int]
        $BuildNumber
    )

    $psGalleryName = 'PSGallery'

    # Test if the repository is registered.
    Write-Verbose ("Checking if Repository: {0} is registered." -f $RepositoryName)
    if (!(Get-PSRepository -Name $RepositoryName -ErrorAction SilentlyContinue)) {
        # Check if the Network Path exists.
        if(!(Test-Path $RepositoryPath)) {
            throw "The path does not exist. Please connect to the share."
        } else {
            # Register the Repository.
            if ($RepositoryName -ne $psGalleryName) {
                Write-Verbose("Registering Repository: {0}." -f $RepositoryName)
                Register-PSRepository 
                    -Name $RepositoryName 
                    -SourceLocation $RepositoryPath 
                    -PublishLocation $RepositoryPath 
                    -InstallationPolicy Trusted
            }
        }
    }

    # Update existing manifest.
    Write-Verbose("Checking if Module: {0} is registered." -f $ModuleName)
    if (Find-Module -Repository $RepositoryName -Name $ModuleName -ErrorAction SilentlyContinue) {
        Write-Verbose ("Updating Manifest for: {0}." -f $ModuleName)
        $version = (Get-Module -FullyQualifiedName $ModulePath -ListAvailable).Version | Select-Object Major, Minor
        $newVersion = New-Object Version -ArgumentList $version.major, $version.minor, $BuildNumber
        Update-ModuleManifest -Path $ModulePath -ModuleVersion $newVersion
    }

    # Publish Module.
    Write-Verbose ("Publishing Module: {0}." -f $ModuleName)

    $publishParams = @{
        Path = ".\$ModuleName"
    }
    # Determine type of publish.
    if ($RepositoryName -eq $psGalleryName) {
        if ([string]::IsNullOrEmpty($ApiKey)) {
            throw("Please pass on a NuGet API key to deploy to the PSGallery.")
        } else {
            $publishParams.NuGetApiKey = $ApiKey
        }
    } else {
        $publishParams.Repository = $RepositoryName
    }

    try {

        Publish-Module @publishParams

    } catch [System.Exception] {
        throw($_.Exception)
    }
}