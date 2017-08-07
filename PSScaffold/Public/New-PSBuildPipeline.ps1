<#
.SYNOPSIS
Creates a new build pipeline.

.DESCRIPTION
Creates build pipeline files and scaffolds base structure, to the target module.

.PARAMETER Module
The name of a module, or the parent path of a module manifest.

.NOTES
This scaffolding script is inspired by The PowerShell Build Pipeline as proposed by xainey (Michael Willis):
https://xainey.github.io/2017/powershell-module-pipeline/

Written by Karl Wallenius, Redeploy AB.
#>
function New-PSBuildPipeline {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $False, Position = 0)]
        [string]
        $Module
    )

    begin {
        # Import templates from variables.
        . "$PSScriptRoot\..\templates\t_build.ps1"
        . "$PSScriptRoot\..\templates\t_build_settings.ps1"
        . "$PSScriptRoot\..\templates\t_build_utils.ps1"
        . "$PSScriptRoot\..\templates\t_gitignore.ps1"
    }

    process {
        $modulePath = $null

        # Determine if a path was used as Module.
        if ($Module.Contains("\")) {
            if (!(Test-Path $Module)) {
                throw "A module with that path does not exist."
            }
            $modulePath = $Module.Trim("\")
        } else {

            if ($Module -eq ".") {
                $path = (Resolve-Path $Module).Path
            } else {
                $path = (Get-Location).Path
            }

            $modulePath = $path 
        }

        $moduleName = Split-Path $modulePath -Leaf

        $buildFilePath = Join-Path $modulePath "$moduleName.build.ps1"
        $buildSettingsFilePath = Join-Path $modulePath "$moduleName.settings.ps1"
        $buildUtilsFilePath = Join-Path $modulePath "build_utils.ps1"
        $gitIgnoreFilePath = Join-Path $modulePath ".gitignore"

        Write-Verbose "Creating build file."
        New-Item $buildFilePath | Out-Null
        $BuildFileContent -replace "<module>", "$moduleName" | Out-File $buildFilePath -Encoding utf8

        Write-Verbose "Creating build settings file."
        New-Item $buildSettingsFilePath | Out-Null
        $BuildSettingsFileContent -replace "<module>", "$moduleName" | Out-File $buildSettingsFilePath -Encoding utf8
            
        Write-Verbose "Creating build utilities file."
        New-Item $buildUtilsFilePath | Out-Null
        $BuildUtilsFileContent | Out-File $buildUtilsFilePath -Encoding utf8

        Write-Verbose "Creating .gitignore file."
        New-Item $gitIgnoreFilePath | Out-Null
        $GitIgnoreFileContent | Out-File $gitIgnoreFilePath -Encoding utf8 
    }
}
