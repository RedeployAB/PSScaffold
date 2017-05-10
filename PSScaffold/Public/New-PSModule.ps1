<#
.SYNOPSIS
    Scaffolds new module structure.
.DESCRIPTION
    Function to initialize and scaffolc the structure for a PowerShell script/function module.
.PARAMETER Path
    <String> Path to where the module should be created.
.PARAMETER ModuleName
    <String> The name of the module.
.PARAMETER Author
    <String> Name of the author.
.PARAMETER Description
    <String> Description of the module.
.NOTES
    This scaffolding script is inspired by Rambling Cookie Monster,
    http://ramblingcookiemonster.github.io/Building-A-PowerShell-Module/

    For yet more advanced features, modify the resulting module manifest manually.

    Made as a function in a module by Karl Wallenius, Redeploy AB.
#>
function New-PSModule {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $True, Position = 0)]
        [string]
        $Name,
        [Parameter(Mandatory = $False, Position = 1)]
        [string]
        $Path,
        [Parameter(Mandatory = $True, Position = 2)]
        [string]
        $Author,
        [Parameter(Mandatory = $False, Position = 3)]
        [string]
        $Description,
        [Parameter(Mandatory = $False)]
        [switch]
        $BuildPipeline
    )

    begin {
        # Import templates from variables.
        . "$PSScriptRoot\..\templates\t_module.ps1"
        . "$PSScriptRoot\..\templates\t_help.ps1"

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

        New-Item -ItemType Directory -Path "$Path\$Name\$Name" | Out-Null
        New-Item -ItemType Directory -Path "$Path\$Name\$Name\Private" | Out-Null
        New-Item -ItemType Directory -Path "$Path\$Name\$Name\Public" | Out-Null
        New-Item -ItemType Directory -Path "$Path\$Name\$Name\en-US" | Out-Null
        New-Item -ItemType Directory -Path "$Path\$Name\Tests" | Out-Null
        New-Item -ItemType Directory -Path "$Path\$Name\Tests\Private" | Out-Null
        New-Item -ItemType Directory -Path "$Path\$Name\Tests\Public" | Out-Null

        Write-Verbose "Creating module project files."
        
        New-Item "$Path\$Name\$Name\$Name.psm1" -ItemType File | Out-Null
        New-Item "$Path\$Name\$Name\en-US\about_$Name.help.txt" -ItemType File | Out-Null
        New-Item "$Path\$Name\README.md" -ItemType File | Out-Null
        

        $moduleParams = @{
            Path = "$Path\$Name\$Name\$Name.psd1"
            RootModule = "$Name.psm1"
            Description = $Description
            PowerShellVersion = "3.0"
            Author = $Author
        }

        New-ModuleManifest @moduleParams

        Write-Verbose "Creating module script file."
        $ModuleFileContent | Out-File "$Path\$Name\$Name\$Name.psm1" -Encoding utf8

        Write-Verbose "Creating help file."
        $HelpFileContent -replace "<module>", "$Name" | Out-File "$Path\$Name\$Name\en-US\about_$Name.help.txt" -Encoding utf8


        $ReadmeContent = "# $Name" | Out-File "$Path\$Name\README.md" -Encoding utf8

        # Content for build and build settings.

        if ($BuildPipeline) {
            
            New-PSBuildPipeline -Module "$Path\$Name"
        }
    }
}