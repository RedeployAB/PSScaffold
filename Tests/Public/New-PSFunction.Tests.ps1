$here = (Split-Path -Parent $MyInvocation.MyCommand.Path).Replace((Join-Path "Tests" "Public"), (Join-Path "PSScaffold" "Public"))
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

. (Join-Path $here $sut)

Import-Module (Resolve-Path .\PSScaffold\PSScaffold.psm1) -Force -NoClobber

InModuleScope "PSScaffold" {

    Describe "New-PSFunction" {
        
        $begin = (Get-Location).Path

        $testPath = Merge-Path ([IO.Path]::GetTempPath()), "ModuleFolder"
        $testName = "ATestModule"

        $testProjectPath = Merge-Path $testPath, $testName
        $testModulePath = Merge-Path $testProjectPath, $testName

        New-PSModule -Name $testName -Path $testPath -Author 'Test' -Description 'Test'

        It "Should create the function if you are in the project root directory without a path" {
            
            Set-Location $testProjectPath

            New-PSFunction -Name "New-Test"
            
            Set-Location $begin
            
            { Test-Path (Merge-Path $testModulePath, "Public", "New-Test.ps1") } | Should Be $true

        }

        It "Should create the function if you are in the project root directory without a '.'" {
            
            Set-Location $testProjectPath

            New-PSFunction -Name "New-TestB" "."
            
            Set-Location $begin
            
            { Test-Path (Merge-Path $testModulePath, "Public", "New-TestB.ps1") } | Should Be $true
        }

        It "Should create the function at the specified module path" {

            New-PSFunction -Name "New-TestC" -Module $testProjectPath

            { Test-Path (Merge-Path $testModulePath, "Public", "New-TestC.ps1") } | Should Be $true
        }

        It "Should create the function from the template" {
            . (Merge-Path $PSScriptRoot, "..", "..", "PSScaffold", "templates", "t_function.ps1")

            $FunctionFileContent -replace "<name>", "New-Test" | Out-File "TestDrive:\temp.ps1"

            $expectedContent = Get-Content "TestDrive:\temp.ps1"

            $functionContent = Get-Content (Merge-Path $testModulePath, "Public", "New-Test.ps1")

            $functionContent | Should Be $expectedContent 
        }

        It "Should create the function with a pester test" {

            Set-Location $testProjectPath

            New-PSFunction -Name "New-TestD" -Module $testProjectPath -PesterTest
            
            Set-Location $begin
            
            { Test-Path (Merge-Path $testModulePath, "Public", "New-TestD.ps1") } | Should Be $true
            { Test-Path (Merge-Path $testProjectPath, "Tests", "Public", "New-TestD.Tests.ps1") } | Should Be $true
        }

        It "Should throw if a module path if the path does not exist" {

            { New-PSFunction -Name "New-TestE" -Module (Merge-Path $testPath, "BTestModule") } | Should throw
        }

        Remove-Item $testPath -Recurse -Force
    }

}

Remove-Module PSScaffold -Force
