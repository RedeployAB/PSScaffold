$here = (Split-Path -Parent $MyInvocation.MyCommand.Path).Replace((Join-Path "Tests" "Private"), (Join-Path "PSScaffold" "Private"))
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

. (Join-Path $here $sut)

Import-Module (Resolve-Path .\PSScaffold\PSScaffold.psm1) -Force -NoClobber

InModuleScope "PSScaffold" {

    Describe "Get-ModulePath" {
    
        $Separator = [System.IO.Path]::DirectorySeparatorChar

        It "Should return the current location if no parameter is provided" {
            $currentPath = (Get-Location).Path
            $modulePath = Get-ModulePath

            ($modulePath -eq $currentPath) | Should be $true
        }

        It "Should resolve a relative path into a full path" {
            $providedPath = "."
            $resolvedPath = (Resolve-Path -Path $providedPath).Path
            $modulePath = Get-ModulePath -Path $providedPath

            ($modulePath -eq $resolvedPath) | Should be $true
        }

        It "Should throw if the path is invalid" {
            $providedPath = "*?InvalidPath$($Separator)"

            { Get-ModulePath -Path $providedPath } | Should throw
        }

        It "Should throw if the path does not exist" {
            $providedPath = (Merge-Path "This", "Path", "Does", "Not", "Exist")

            { Get-ModulePath -Path $providedPath } | Should throw
        }

        It 'Should not return $null' {
            { Get-ModulePath -Path (Get-Location).Path } | Should not be $null
            { Get-ModulePath -Path "." } | Should not be $null
            { Get-ModulePath } | Should not be $null
        }

    }

}
