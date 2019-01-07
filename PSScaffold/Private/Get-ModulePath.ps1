<#
.SYNOPSIS
Validates and/or resolves the provided path.

.DESCRIPTION
If a relative/provided path is valid, it is cleaned and returned. If the current
path (.) is provided it is resolved and returned. Is there no path
provided, the current location is returned.

.PARAMETER Path
Path to the module project directory.

.EXAMPLE
Resolves the current directory's full path

Get-ModulePath -Path "."
#>
function Get-ModulePath {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [string]
        $Path
    )

    begin {
        $ModulePath = $null
        $Separator = [System.IO.Path]::DirectorySeparatorChar
    }

    process {
        if ($Path.Contains($Separator)) {
            if (!(Test-Path $Path)) {
                throw "A module with that path does not exist."
            }

            $ModulePath = $Path.TrimEnd($sep)
        } else {
            if ($Path -eq ".") {
                $ResolvedPath = (Resolve-Path $Path).Path
            } else {
                $ResolvedPath = (Get-Location).Path
            }

            $ModulePath = $ResolvedPath 
        }

        $ModulePath
    }
}
