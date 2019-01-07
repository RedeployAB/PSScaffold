$here = (Split-Path -Parent $MyInvocation.MyCommand.Path).Replace((Join-Path "Tests" "Public"), (Join-Path "PSScaffold" "Public"))
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

. (Join-Path $here $sut)

Import-Module (Resolve-Path .\PSScaffold\PSScaffold.psm1) -Force -NoClobber

InModuleScope "PSScaffold" {

    Describe "New-PSBuildPipeline" {

        $begin = (Get-Location).Path

        $testPath = Merge-Path ([IO.Path]::GetTempPath()), "ModuleFolder"
        $testName = "ATestModule"

        $testProjectPath = Merge-Path $testPath, $testName
        $testModulePath = Merge-Path $testProjectPath, $testName

        New-PSModule -Name $testName -Path $testPath -Author 'Test' -Description 'Test'
        # Create the build files.
        New-PSBuildPipeline -Module $testProjectPath

        It "Should create the needed build files" {

            { Test-Path (Merge-Path $testModulePath, "build_utils.ps1") } | Should Be $true
            { Test-Path (Merge-Path $testModulePath, "$testName.build.ps1") } | Should Be $true
            { Test-Path (Merge-Path $testModulePath, "$testName.settings.ps1") } | Should Be $true
            { Test-Path (Merge-Path $testModulePath, ".gitignore") } | Should Be $true

            Remove-Item $testProjectPath -Recurse -Force
        }
        It "Should create the build pipeline if invoked from the project root without path" {
            
            New-PSModule -Name $testName -Path $testPath -Author 'Test' -Description 'Test'

            Set-Location $testProjectPath

            New-PSBuildPipeline

            Set-Location $begin

            { Test-Path (Merge-Path $testModulePath, "build_utils.ps1") } | Should Be $true
            { Test-Path (Merge-Path $testModulePath, "$testName.build.ps1") } | Should Be $true
            { Test-Path (Merge-Path $testModulePath, "$testName.settings.ps1") } | Should Be $true
            { Test-Path (Merge-Path $testModulePath, ".gitignore") } | Should Be $true

            Remove-Item $testProjectPath -Recurse -Force
        }

        It "Should create the build pipeline if invoked from the project root and '.' is specified" {
            
            New-PSModule -Name $testName -Path $testPath -Author 'Test' -Description 'Test'

            Set-Location $testProjectPath

            New-PSBuildPipeline -Module "."

            Set-Location $begin

            { Test-Path (Merge-Path $testModulePath, "build_utils.ps1") } | Should Be $true
            { Test-Path (Merge-Path $testModulePath, "$testName.build.ps1") } | Should Be $true
            { Test-Path (Merge-Path $testModulePath, "$testName.settings.ps1") } | Should Be $true
            { Test-Path (Merge-Path $testModulePath, ".gitignore") } | Should Be $true

            Remove-Item $testProjectPath -Recurse -Force            
        }

        It "Should create the build pipeline if a valid module path is specified" {
            
            New-PSModule -Name $testName -Path $testPath -Author 'Test' -Description 'Test'
            
            New-PSBuildPipeline -Module $testProjectPath

            { Test-Path (Merge-Path $testModulePath, "build_utils.ps1") } | Should Be $true
            { Test-Path (Merge-Path $testModulePath, "$testName.build.ps1") } | Should Be $true
            { Test-Path (Merge-Path $testModulePath, "$testName.settings.ps1") } | Should Be $true
            { Test-Path (Merge-Path $testModulePath, ".gitignore") } | Should Be $true

            Remove-Item $testProjectPath -Recurse -Force            
        }

        It "Should throw if module does not exist at that path" {
            { New-PSBuildPipeline -Module (Merge-Path $testPath, "BTestModule") } | Should throw
        }

        Remove-Item $testPath -Recurse -Force
    }

}

Remove-Module PSScaffold -Force
