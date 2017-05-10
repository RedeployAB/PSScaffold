$here = (Split-Path -Parent $MyInvocation.MyCommand.Path).Replace("Tests\Public","PSScaffold\Public")
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

. "$here\$sut"

Import-Module (Resolve-Path .\PSScaffold\PSScaffold.psm1) -Force -NoClobber

InModuleScope "PSScaffold" {

    Describe "New-PSModule" {

        $testPath = "$env:TEMP\ModuleFolder"
        $testName = "ATestModule"

        $testModulePath = "$testPath\$testName\$testName"

        $begin = (Get-Location).Path

        New-PSModule -Name $testName -Path $testPath -Author 'Test' -Description 'Test'

        It "Should create the necessary files and folders" {
            { Test-Path "$testPath\$testName" } | Should be $true
            { Test-Path "$testModulePath" } | Should be $true
            { Test-Path "$testModulePath\en-US" } | Should be $true
            { Test-Path "$testModulePath\en-US\about_$testName.help.txt" } | Should be $true
            { Test-Path "$testModulePath\Private" } | Should be $true
            { Test-Path "$testModulePath\Public" } | Should be $true
            { Test-Path "$testModulePath\$testName.psd1" } | Should be $true
            { Test-Path "$testModulePath\$testName.psm1" } | Should be $true
            { Test-Path "$testPath\$testName\Tests" } | Should be $true
            { Test-Path "$testPath\$testName\Tests\Private" } | Should be $true
            { Test-Path "$testPath\$testName\Tests\Public" } | Should be $true
            { Test-Path "$testPath\$testName\README.md" }
        }

        It "Should create the file $testName.psm1 with the correct content" {
            . "$PSScriptRoot\..\..\PSScaffold\templates\t_module.ps1"

            $ModuleFileContent | Out-File "TestDrive:\temp.ps1"
            $expectedContent = Get-Content "TestDrive:\temp.ps1"

            $scriptContent = Get-Content "$testModulePath\$testName.psm1" 

            $scriptContent | Should Be $expectedContent
        }

        It "Should create a help file with the correct content" {

            $helpFileContent = Get-Content "$testModulePath\en-US\about_$testName.help.txt"

            "$testModulePath\en-US\about_$testName.help.txt" | Should Contain "about_$testName"
        }

        Remove-Item "$testPath\$testName" -Recurse -Force

        It "Should create the project in the current directory if no path is specified" {
            Set-Location $testPath

            New-PSModule -Name $testName -Author 'Test' -Description 'Test'

            Set-Location $begin

            { Test-Path "$testPath\$testName" } | Should be $true
            { Test-Path "$testModulePath" } | Should be $true
            { Test-Path "$testModulePath\en-US" } | Should be $true
            { Test-Path "$testModulePath\en-US\about_$testName.help.txt" } | Should be $true
            { Test-Path "$testModulePath\Private" } | Should be $true
            { Test-Path "$testModulePath\Public" } | Should be $true
            { Test-Path "$testModulePath\$testName.psd1" } | Should be $true
            { Test-Path "$testModulePath\$testName.psm1" } | Should be $true
            { Test-Path "$testPath\$testName\Tests" } | Should be $true
            { Test-Path "$testPath\$testName\Tests\Private" } | Should be $true
            { Test-Path "$testPath\$testName\Tests\Public" } | Should be $true
            { Test-Path "$testPath\$testName\README.md" }

            Remove-Item "$testPath\$testName" -Recurse -Force
        }

        It "Should create the project in the current directory if '.' is specified" {
            Set-Location $testPath

            New-PSModule -Name $testName -Path "." -Author 'Test' -Description 'Test'

            Set-Location $begin

            { Test-Path "$testPath\$testName" } | Should be $true
            { Test-Path "$testModulePath" } | Should be $true
            { Test-Path "$testModulePath\en-US" } | Should be $true
            { Test-Path "$testModulePath\en-US\about_$testName.help.txt" } | Should be $true
            { Test-Path "$testModulePath\Private" } | Should be $true
            { Test-Path "$testModulePath\Public" } | Should be $true
            { Test-Path "$testModulePath\$testName.psd1" } | Should be $true
            { Test-Path "$testModulePath\$testName.psm1" } | Should be $true
            { Test-Path "$testPath\$testName\Tests" } | Should be $true
            { Test-Path "$testPath\$testName\Tests\Private" } | Should be $true
            { Test-Path "$testPath\$testName\Tests\Public" } | Should be $true
            { Test-Path "$testPath\$testName\README.md" }

            Remove-Item "$testPath\$testName" -Recurse -Force
        }

        It "Should create the project with a build pipline if switch is used" {
            Set-Location $testPath

            New-PSModule -Name $testName -Path $testPath -Author 'Test' -Description 'Test' -BuildPipeline

            Set-Location $begin

            { Test-Path "$testPath\$testName" } | Should be $true
            { Test-Path "$testModulePath" } | Should be $true
            { Test-Path "$testModulePath\en-US" } | Should be $true
            { Test-Path "$testModulePath\en-US\about_$testName.help.txt" } | Should be $true
            { Test-Path "$testModulePath\Private" } | Should be $true
            { Test-Path "$testModulePath\Public" } | Should be $true
            { Test-Path "$testModulePath\$testName.psd1" } | Should be $true
            { Test-Path "$testModulePath\$testName.psm1" } | Should be $true
            { Test-Path "$testPath\$testName\Tests" } | Should be $true
            { Test-Path "$testPath\$testName\Tests\Private" } | Should be $true
            { Test-Path "$testPath\$testName\Tests\Public" } | Should be $true
            { Test-Path "$testPath\$testName\README.md" }

            { Test-Path "$testModulePath\build_utils.ps1" } | Should Be $true
            { Test-Path "$testModulePath\$testName.build.ps1" } | Should Be $true
            { Test-Path "$testModulePath\$testName.settings.ps1" } | Should Be $true
            { Test-Path "$testModulePath\.gitignore" } | Should Be $true

            Remove-Item "$testPath\$testName" -Recurse -Force
        }
    }
}
