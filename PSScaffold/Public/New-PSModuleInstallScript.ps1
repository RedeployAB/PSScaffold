<#
.SYNOPSIS
.DESCRIPTION
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
