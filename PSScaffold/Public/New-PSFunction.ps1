<#
.SYNOPSIS
Creates a new function file.

.DESCRIPTION
Creates a new function file and scaffolds base structure, to the target module.

.PARAMETER Name
The name of the function to create.    

.PARAMETER Module
The name of a module, or the parent path of a module manifest.

.PARAMETER Scope
The scope of the function according to Redeploy scaffolding standards. Allowed values: Private and Public. Default: Public.

.PARAMETER PesterTest
If used, a Pester Test file will be created in the module.

.NOTES
    Written by Karl Wallenius, Redeploy AB.
#>
function New-PSFunction {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]
        $Name,
        [Parameter(Mandatory = $false, Position = 1)]
        [string]
        $Module,
        [Parameter(Mandatory = $false, Position = 2)]
        [ValidateSet('Public', 'Private')]
        [string]
        $Scope = "Public",
        [Parameter(Mandatory = $false)]
        [switch]
        $PesterTest = $false
    )

    process {

        $TemplatesPath = Merge-Path $PSScriptRoot, "..", "templates"
        . (Merge-Path $TemplatesPath, "t_function.ps1")

        $modulePath = Get-ModulePath -Path $Module
        $moduleName = Split-Path $modulePath -Leaf

        $fileName = $Name + ".ps1"
        $filePath = Merge-Path $modulePath, $moduleName, $Scope, $fileName

        Write-Verbose "Creating function template..."
        $FunctionFileContent -replace "<name>", "$Name" | Out-File $filePath -Encoding utf8
        Write-Verbose "Function template is done."

        if ($PesterTest) {
            New-PSPesterTest -Module $modulePath -Name $Name -Scope $Scope
        }
    }
}
