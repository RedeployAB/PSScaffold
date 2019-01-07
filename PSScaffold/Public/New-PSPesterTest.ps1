<#
.SYNOPSIS
Creates a new Pester Test file.

.DESCRIPTION
Function to scaffold the structure of a test file for Pester tests.

.PARAMETER Name
The name of the function to create a test for.

.PARAMETER Module
The name of a module, or the parent path of a module manifest.

.PARAMETER Scope
The scope of the function according to Redeploy scaffolding standards. Allowed values: Private and Public. Default: Public.

.EXAMPLE
To create a new Pester test for the function New-Action in Module 'MyModule', by Module name, and place it in the public scope.

New-REPesterTest -Name New-Action -Module MyModule 

.EXAMPLE
To create a new Pester test for the function New-Action in Module 'MyModule', by Module path, and place it in the public scope.

New-PSPesterTest -Name New-Action -Module C:\Users\JohnSmith\Documents\Projects\Modules\MyModule 

.NOTES
    Written by Karl Wallenius, Redeploy AB.
#>
function New-PSPesterTest {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]
        $Name,
        [Parameter(Mandatory = $false, Position = 1)]
        [string]
        $Module,
        [Parameter(Mandatory = $false, Position = 2)]
        [ValidateSet('Private', 'Public')]
        [string]
        $Scope = "Public"
    )

    process {

        $TemplatesPath = Merge-Path $PSScriptRoot, "..", "templates"
        . (Merge-Path $TemplatesPath, "t_pestertest.ps1")

        $modulePath = Get-ModulePath -Path $Module
        $moduleName = Split-Path $modulePath -Leaf
        
        $fileName = $Name + ".Tests.ps1"
        $filePath = Merge-Path $modulePath, "Tests", $Scope, $fileName

        Write-Verbose "Creating test file template..."
        $PesterFileContent -replace "<module>", "$moduleName" -replace "<scope>","$Scope" -replace "<name>", "$Name" | 
            Out-File $filePath -Encoding utf8
        Write-Verbose "Test file template is done."
    }
}
