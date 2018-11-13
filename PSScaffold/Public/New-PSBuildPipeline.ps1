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
        [Parameter(Mandatory = $false, Position = 0)]
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
        [void](New-Item -Path $buildFilePath -ItemType File)
        $BuildFileContent -replace "<module>", "$moduleName" | Set-Content -Path $buildFilePath -Encoding utf8

        Write-Verbose "Creating build settings file."
        [void](New-Item -Path $buildSettingsFilePath -ItemType File)
        $BuildSettingsFileContent -replace "<module>", "$moduleName" | Set-Content -Path $buildSettingsFilePath -Encoding utf8
            
        Write-Verbose "Creating build utilities file."
        [void](New-Item -Path $buildUtilsFilePath -ItemType File)
        $BuildUtilsFileContent | Set-Content -Path $buildUtilsFilePath -Encoding utf8

        Write-Verbose "Creating .gitignore file."
        [void](New-Item -Path $gitIgnoreFilePath -ItemType File)
        $GitIgnoreFileContent | Set-Content -Path $gitIgnoreFilePath -Encoding utf8 
    }
}
