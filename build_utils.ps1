<#
.SYNOPSIS
    Published a PowerShell Module to a network share.
#>
function Publish-SMBModule {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]
        $RepositoryName,
        [Parameter(Mandatory=$true)]
        [string]
        $RepositoryPath,
        [Parameter(Mandatory=$true)]
        [string]
        $ModuleName,
        [Parameter(Mandatory=$true)]
        [string]
        $ModulePath,
        [Parameter(Mandatory=$true)]
        [int]
        $BuildNumber
    )

    # Test if the repository is registered.
    Write-Verbose ("Checking if Repository: {0} is registered." -f $RepositoryName)
    if (!(Get-PSRepository -Name $RepositoryName -ErrorAction SilentlyContinue)) {
        # Check if the Network Path exists.
        if(!(Test-Path $RepositoryPath)) {
            throw "The path does not exist. Please connect to the share."
        } else {
            # Register the Repository.
            Write-Verbose("Registering Repository: {0}." -f $RepositoryName)
            Register-PSRepository 
                -Name $RepositoryName 
                -SourceLocation $RepositoryPath 
                -PublishLocation $RepositoryPath 
                -InstallationPolicy Trusted
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

    try {

        Publish-Module -Repository $RepositoryName -Path ".\$ModuleName"

    } catch [System.Exception] {
        throw($_.Exception)
    }
}
