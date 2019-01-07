$here = (Split-Path -Parent $MyInvocation.MyCommand.Path).Replace((Join-Path "Tests" "Public"), (Join-Path "PSScaffold" "Public"))
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

. (Join-Path $here $sut)

Import-Module (Resolve-Path .\PSScaffold\PSScaffold.psm1) -Force -NoClobber

InModuleScope "PSScaffold" {

    Describe "New-PSPesterTest" {
        
        $begin = (Get-Location).Path

        $testPath = Merge-Path ([IO.Path]::GetTempPath()), "ModuleFolder"
        $testName = "ATestModule"

        $testProjectPath = Merge-Path $testPath, $testName
        $pesterTestsPath = Merge-Path $testProjectPath, "Tests", "Public"

        New-PSModule -Name $testName -Path $testPath -Author 'Test' -Description 'Test'

        It "Should create the function if you are in the project root directory without a path" {
            
            Set-Location $testProjectPath

            New-PSPesterTest -Name "New-Test"
            
            Set-Location $begin
            
            { Test-Path (Merge-Path $pesterTestsPath, "New-Test.Tests.ps1") } | Should Be $true

        }

        It "Should create the function if you are in the project root directory without a '.'" {
            
            Set-Location $testProjectPath

            New-PSPesterTest -Name "New-TestB" "."
            
            Set-Location $begin
            
            { Test-Path (Merge-Path $pesterTestsPath, "New-TestB.Tests.ps1") } | Should Be $true
        }

        It "Should create the function at the specified module path" {

            Set-Location $testProjectPath

            New-PSPesterTest -Name "New-TestC" -Module $testProjectPath

            Set-Location $begin

            { Test-Path (Merge-Path $pesterTestsPath, "New-TestC.Tests.ps1") } | Should Be $true
        }

        It "Should create the function from the template" {
            . (Merge-Path $PSScriptRoot, "..", "..", "PSScaffold", "templates", "t_pestertest.ps1")

            $PesterFileContent -replace "<name>","New-Test" -replace "<module>",$testName -replace "<scope>","Public" | Out-File "TestDrive:\temp.ps1"

            $expectedContent = Get-Content "TestDrive:\temp.ps1"

            $functionContent = Get-Content (Merge-Path $pesterTestsPath, "New-Test.Tests.ps1")

            $functionContent | Should Be $expectedContent 
        }

        It "Should throw if a module path is provided and the path does not exist" {
            
            { New-PSPesterTest -Name "New-TestE" -Module (Merge-Path $testPath, "BTestModule") } | Should throw
        }

        Remove-Item $testPath -Recurse -Force
    }

}

Remove-Module PSScaffold -Force
