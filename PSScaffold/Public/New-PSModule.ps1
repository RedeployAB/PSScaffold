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
        $TemplatesPath = Merge-Path $PSScriptRoot, "..", "templates"
        . (Merge-Path $TemplatesPath, "t_module.ps1")
        . (Merge-Path $TemplatesPath, "t_help.ps1")
        . (Merge-Path $TemplatesPath, "t_readme.ps1")

        # Handle the path to the module.
        $sep = ([IO.Path]::DirectorySeparatorChar)

        if ([string]::IsNullOrEmpty($Path)) {
            $Path = (Get-Location).Path
        } elseif ($Path -eq ".") {
            $Path = (Resolve-Path ".").Path
        } else {
            $Path = $Path.TrimEnd($sep)
        }
    }
    #>
    process {
        # Create directories for the project
        Write-Verbose "Creating directory structure."

        $ProjectPath = Merge-Path $Path, $Name
        $ModulePath = Merge-Path $ProjectPath, $Name
        $TestsPath = Merge-Path $ProjectPath, "Tests"
        $Locale = "en-US"

        [void](New-Item -ItemType Directory -Path (Merge-Path $ModulePath))
        [void](New-Item -ItemType Directory -Path (Merge-Path $ModulePath, "Private"))
        [void](New-Item -ItemType Directory -Path (Merge-Path $ModulePath, "Public"))
        [void](New-Item -ItemType Directory -Path (Merge-Path $ModulePath, $Locale))
        [void](New-Item -ItemType Directory -Path (Merge-Path $TestsPath))
        [void](New-Item -ItemType Directory -Path (Merge-Path $TestsPath, "Private"))
        [void](New-Item -ItemType Directory -Path (Merge-Path $TestsPath, "Public"))

        # Create files for the project
        Write-Verbose "Creating module project files."

        $ModuleFileName = "$Name.psm1"
        $ModuleFilePath = Merge-Path $ModulePath, $ModuleFileName
        $ManifestFileName = "$Name.psd1"
        $ManifestFilePath = Merge-Path $ModulePath, $ManifestFileName
        $HelpFileName = "about_$Name.help.txt"
        $HelpFilePath = Merge-Path $ModulePath, $Locale, $HelpFileName
        $ReadmeName = "README.md"
        $ReadmePath = Merge-Path $ProjectPath, $ReadmeName
        
        [void](New-Item $ModuleFilePath -ItemType File)
        [void](New-Item (Merge-Path $ModulePath, $Locale, $HelpFileName) -ItemType File)      

        $getModuleParams = @{
            Path = $ManifestFilePath
            RootModule = $ModuleFileName
            Description = $Description
            PowerShellVersion = "3.0"
            Author = $Author
            ModuleVersion = "0.1.0"
        }

        New-ModuleManifest @getModuleParams

        Write-Verbose "Creating module script file."
        $ModuleFileContent | Out-File $ModuleFilePath -Encoding utf8

        Write-Verbose "Creating help file."
        $HelpFileContent -replace "<module>", "$Name" | Out-File $HelpFilePath -Encoding utf8

        Write-Verbose "Creating $ReadmeName file."
        $ReadmeContent -replace "<module>", "$Name" | Out-File $ReadmePath -Encoding utf8 

        if ($BuildPipeline) {
            New-PSBuildPipeline -Module $ProjectPath
        }
    }
}
