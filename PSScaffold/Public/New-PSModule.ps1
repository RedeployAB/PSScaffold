<#
.SYNOPSIS
Scaffolds new module structure.

.DESCRIPTION
Function to initialize and scaffolc the structure for a PowerShell script/function module.

.PARAMETER Name
The name of the module.

.PARAMETER Path
Path to where the module should be created.

.PARAMETER Author
Name of the author.

.PARAMETER Description
Description of the module.

.PARAMETER BuildPipeline
Switch to determine if Build Pipeline for Invoke-Build should be setup
along with the module.

.NOTES
This scaffolding script is inspired by Rambling Cookie Monster,
http://ramblingcookiemonster.github.io/Building-A-PowerShell-Module/

For yet more advanced features, modify the resulting module manifest manually.

Made as a function in a module by Karl Wallenius, Redeploy AB.
#>
function New-PSModule {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]
        $Name,
        [Parameter(Mandatory = $false, Position = 1)]
        [string]
        $Path,
        [Parameter(Mandatory = $true, Position = 2)]
        [string]
        $Author,
        [Parameter(Mandatory = $false, Position = 3)]
        [string]
        $Description,
        [Parameter(Mandatory = $false)]
        [switch]
        $BuildPipeline
    )

    begin {
        # Import templates from variables.
        . "$PSScriptRoot\..\templates\t_module.ps1"
        . "$PSScriptRoot\..\templates\t_help.ps1"
        . "$PSScriptRoot\..\templates\t_readme.ps1"

        # Handle the path of the module.
        if ([string]::IsNullOrEmpty($Path)) {
            $Path = (Get-Location).Path
        } elseif ($Path -eq ".") {
            $Path = (Resolve-Path ".").Path
        } else {
            $Path = $Path.Trim("\")
        }
    }
    #>
    process {
        # Create directories for the project
        Write-Verbose "Creating directory structure."

        [void](New-Item -ItemType Directory -Path "$Path\$Name\$Name")
        [void](New-Item -ItemType Directory -Path "$Path\$Name\$Name\Private")
        [void](New-Item -ItemType Directory -Path "$Path\$Name\$Name\Public")
        [void](New-Item -ItemType Directory -Path "$Path\$Name\$Name\en-US")
        [void](New-Item -ItemType Directory -Path "$Path\$Name\Tests")
        [void](New-Item -ItemType Directory -Path "$Path\$Name\Tests\Private")
        [void](New-Item -ItemType Directory -Path "$Path\$Name\Tests\Public")

        Write-Verbose "Creating module project files."
        
        [void](New-Item "$Path\$Name\$Name\$Name.psm1" -ItemType File)
        [void](New-Item "$Path\$Name\$Name\en-US\about_$Name.help.txt" -ItemType File)      

        $moduleParams = @{
            Path = "$Path\$Name\$Name\$Name.psd1"
            RootModule = "$Name.psm1"
            Description = $Description
            PowerShellVersion = "3.0"
            Author = $Author
            ModuleVersion = "0.1.0"
        }

        New-ModuleManifest @moduleParams

        Write-Verbose "Creating module script file."
        $ModuleFileContent | Out-File "$Path\$Name\$Name\$Name.psm1" -Encoding utf8

        Write-Verbose "Creating help file."
        $HelpFileContent -replace "<module>", "$Name" | Out-File "$Path\$Name\$Name\en-US\about_$Name.help.txt" -Encoding utf8

        Write-Verbose "Creating README.md file."
        $ReadmeContent -replace "<module>", "$Name" | Out-File "$Path\$Name\README.md" -Encoding utf8 

        if ($BuildPipeline) {
            New-PSBuildPipeline -Module "$Path\$Name"
        }
    }
}
