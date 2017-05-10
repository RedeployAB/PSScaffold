$here = (Split-Path -Parent $MyInvocation.MyCommand.Path).Replace("Tests\Public","PSScaffold\Public")
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

. "$here\$sut"

Import-Module (Resolve-Path .\PSScaffold\PSScaffold.psm1) -Force -NoClobber

InModuleScope "PSScaffold" {

    Describe "New-PSFunction" {
        
        $begin = (Get-Location).Path

        $testPath = "$env:TEMP\ModuleFolder"
        $testName = "ATestModule"

        $testModulePath = "$testPath\$testName\$testName"

        New-PSModule -Name $testName -Path $testPath -Author 'Test' -Description 'Test'

        It "Should create the function if you are in the project root directory without a path" {
            
            Set-Location "$testPath\$testName"

            New-PSFunction -Name "New-Test"
            
            Set-Location $begin
            
            { Test-Path "$testModulePath\Public\New-Test.ps1" } | Should Be $true

        }

        It "Should create the function if you are in the project root directory without a '.'" {
            
            Set-Location "$testPath\$testName"

            New-PSFunction -Name "New-TestB" "."
            
            Set-Location $begin
            
            { Test-Path "$testModulePath\Public\New-TestB.ps1" } | Should Be $true
        }

        It "Should create the function at the specified module path" {

            New-PSFunction -Name "New-TestC" -Module "$testPath\$testName"

            { Test-Path "$testModulePath\Public\New-TestC.ps1" } | Should Be $true
        }

        It "Should create the function from the template" {
            . "$PSScriptRoot\..\..\PSScaffold\templates\t_function.ps1"

            $FunctionFileContent -replace "<name>", "New-Test" | Out-File "TestDrive:\temp.ps1"

            $expectedContent = Get-Content "TestDrive:\temp.ps1"

            $functionContent = Get-Content "$testModulePath\Public\New-Test.ps1"

            $functionContent | Should Be $expectedContent 
        }

        It "Should create the function with a pester test" {

            Set-Location "$testPath\$testName"

            New-PSFunction -Name "New-TestD" -Module "$testPath\$testName" -PesterTest
            
            Set-Location $begin
            
            { Test-Path "$testModulePath\Public\New-TestD.ps1" } | Should Be $true
            { Test-Path "$testPath\$testName\Tests\Public\New-TestD.Tests.ps1" } | Should Be $true
        }

        It "Should throw if a module path if the path does not exist" {

            { New-PSFunction -Name "New-TestE" -Module "$testPath\BTestModule" } | Should throw
        }

        Remove-Item $testPath -Recurse -Force
    }

}
