$here = (Split-Path -Parent $MyInvocation.MyCommand.Path).Replace("Tests\Public","PSScaffold\Public")
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

. "$here\$sut"

Import-Module (Resolve-Path .\PSScaffold\PSScaffold.psm1) -Force -NoClobber

InModuleScope "PSScaffold" {

    Describe "New-PSPesterTest" {
        
        $begin = (Get-Location).Path

        $testPath = "$env:TEMP\ModuleFolder"
        $testName = "ATestModule"

        $testModulePath = "$testPath\$testName\$testName"
        $testFunctionPath = "$testPath\$testName\Tests"

        New-PSModule -Name $testName -Path $testPath -Author 'Test' -Description 'Test'

        It "Should create the function if you are in the project root directory without a path" {
            
            Set-Location "$testPath\$testName"

            New-PSPesterTest -Name "New-Test"
            
            Set-Location $begin
            
            { Test-Path "$testFunctionPath\Public\New-Test.Tests.ps1" } | Should Be $true

        }

        It "Should create the function if you are in the project root directory without a '.'" {
            
            Set-Location "$testPath\$testName"

            New-PSPesterTest -Name "New-TestB" "."
            
            Set-Location $begin
            
            { Test-Path "$testFunctionPath\Public\New-TestB.Tests.ps1" } | Should Be $true
        }

        It "Should create the function at the specified module path" {

            New-PSPesterTest -Name "New-TestC" -Module "$testPath\$testName"

            { Test-Path "$testFunctionPath\Public\New-TestC.Tests.ps1" } | Should Be $true
        }

        It "Should create the function from the template" {
            . "$PSScriptRoot\..\..\PSScaffold\templates\t_pestertest.ps1"

            $PesterFileContent -replace "<name>","New-Test" -replace "<module>",$testName -replace "<scope>","Public" | Out-File "TestDrive:\temp.ps1"

            $expectedContent = Get-Content "TestDrive:\temp.ps1"

            $functionContent = Get-Content "$testFunctionPath\Public\New-Test.Tests.ps1"

            $functionContent | Should Be $expectedContent 
        }

        It "Should throw if a module path if the path does not exist" {

            { New-PSPesterTest -Name "New-TestE" -Module "$testPath\BTestModule" } | Should throw
        }

        Remove-Item $testPath -Recurse -Force
    }

}
