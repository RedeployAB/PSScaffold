$here = (Split-Path -Parent $MyInvocation.MyCommand.Path).Replace("Tests\Public","PSScaffold\Public")
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

. "$here\$sut"

Import-Module (Resolve-Path .\PSScaffold\PSScaffold.psm1) -Force -NoClobber

InModuleScope "PSScaffold" {

    Describe "New-PSBuildPipeline" {

        $testPath = "$env:TEMP\ModuleFolder"
        $testName = "ATestModule"

        $testModulePath = "$testPath\$testName\$testName"

        New-PSModule -Name $testName -Path $testPath -Author 'Test' -Description 'Test'
        # Create the build files.
        New-PSBuildPipeline -Module "$testPath\$testName"

        It "Should create the needed build files" {

            { Test-Path "$testModulePath\build_utils.ps1" } | Should Be $true
            { Test-Path "$testModulePath\$testName.build.ps1" } | Should Be $true
            { Test-Path "$testModulePath\$testName.settings.ps1" } | Should Be $true
            { Test-Path "$testModulePath\.gitignore" } | Should Be $true

            Remove-Item "$testPath\$testName" -Recurse -Force
        }
        It "Should create the build pipline if invoked from the project root without path" {
            
            New-PSModule -Name $testName -Path $testPath -Author 'Test' -Description 'Test'

            $begin = (Get-Location).Path

            Set-Location "$testPath\$testName"

            New-PSBuildPipeline

            Set-Location $begin

            { Test-Path "$testModulePath\build_utils.ps1" } | Should Be $true
            { Test-Path "$testModulePath\$testName.build.ps1" } | Should Be $true
            { Test-Path "$testModulePath\$testName.settings.ps1" } | Should Be $true
            { Test-Path "$testModulePath\.gitignore" } | Should Be $true

            Remove-Item "$testPath\$testName" -Recurse -Force

            
        }

        It "Should create the build pipline if invoked from the project root without path" {
            
            New-PSModule -Name $testName -Path $testPath -Author 'Test' -Description 'Test'
            
            $begin = (Get-Location).Path

            Set-Location "$testPath\$testName"

            New-PSBuildPipeline -Module "."

            Set-Location $begin

            { Test-Path "$testModulePath\build_utils.ps1" } | Should Be $true
            { Test-Path "$testModulePath\$testName.build.ps1" } | Should Be $true
            { Test-Path "$testModulePath\$testName.settings.ps1" } | Should Be $true
            { Test-Path "$testModulePath\.gitignore" } | Should Be $true

            Remove-Item "$testPath\$testName" -Recurse -Force            
        }

        It "Should throw if module does not exist at that path" {
            { New-PSBuildPipeline -Module "$testPath\BTestModule" } | Should throw
        }

        Remove-Item $testPath -Recurse -Force
    }

}
