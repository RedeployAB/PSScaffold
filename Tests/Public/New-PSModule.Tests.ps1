$here = (Split-Path -Parent $MyInvocation.MyCommand.Path).Replace((Join-Path "Tests" "Public"), (Join-Path "PSScaffold" "Public"))
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

. (Join-Path $here $sut)

Import-Module (Resolve-Path .\PSScaffold\PSScaffold.psm1) -Force -NoClobber

InModuleScope "PSScaffold" {

    Describe "New-PSModule" {

        $testPath = Merge-Path ([IO.Path]::GetTempPath()), "ModuleFolder"
        $testName = "ATestModule"

        $testProjectPath = Merge-Path $testPath, $testName
        $testModulePath = Merge-Path $testProjectPath, $testName
        $testFunctionPath = Merge-Path $testProjectPath, "Tests"
        $locale = "en-US"

        $begin = (Get-Location).Path

        New-PSModule -Name $testName -Path $testPath -Author 'Test' -Description 'Test'

        It "Should create the necessary files and folders" {

            { Test-Path (Merge-Path $testProjectPath) } | Should be $true
            { Test-Path (Merge-Path $testProjectPath, "README.md") } | Should Be $true
            { Test-Path (Merge-Path $testModulePath) } | Should be $true
            { Test-Path (Merge-Path $testModulePath, $locale) } | Should be $true
            { Test-Path (Merge-Path $testModulePath, $locale, "about_$testName.help.txt") } | Should be $true
            { Test-Path (Merge-Path $testModulePath, "Private") } | Should be $true
            { Test-Path (Merge-Path $testModulePath, "Public") } | Should be $true
            { Test-Path (Merge-Path $testModulePath, "$testName.psd1") } | Should be $true
            { Test-Path (Merge-Path $testModulePath, "$testName.psm1") } | Should be $true
            { Test-Path (Merge-Path $testFunctionPath) } | Should be $true
            { Test-Path (Merge-Path $testFunctionPath, "Private") } | Should be $true
            { Test-Path (Merge-Path $testFunctionPath, "Public") } | Should be $true
        }

        It "Should create the file $testName.psm1 with the correct content" {
            . (Merge-Path $PSScriptRoot, "..", "..", "PSScaffold", "templates", "t_module.ps1")

            $ModuleFileContent | Out-File "TestDrive:\temp.ps1"
            $expectedContent = Get-Content "TestDrive:\temp.ps1"

            $scriptContent = Get-Content (Merge-Path $testModulePath, "$testName.psm1")

            $scriptContent | Should Be $expectedContent
        }

        It "Should create a help file with the correct content" {

            $helpFileContent = Get-Content (Merge-Path $testModulePath, $locale, "about_$testName.help.txt")

            (Merge-Path $testModulePath, $locale, "about_$testName.help.txt") | Should Match "about_$testName"
        }

        It "Should create a README.md with the correct content" {

            . (Merge-Path $PSScriptRoot, "..", "..", "PSScaffold", "templates", "t_readme.ps1")

            $ReadmeContent -replace "<module>", "$testName" | Out-File "TestDrive:\README.md"
            $expectedContent = Get-Content "TestDrive:\README.md"

            $readmeFileContent = Get-Content (Merge-Path $testProjectPath, "README.md")

            $readmeFileContent | Should Be $expectedContent
        }

        Remove-Item $testProjectPath -Recurse -Force

        It "Should create the project in the current directory if no path is specified" {
            Set-Location $testPath

            New-PSModule -Name $testName -Author 'Test' -Description 'Test'

            Set-Location $begin

            { Test-Path (Merge-Path $testProjectPath) } | Should be $true
            { Test-Path (Merge-Path $testProjectPath, "README.md") } | Should Be $true
            { Test-Path (Merge-Path $testModulePath) } | Should be $true
            { Test-Path (Merge-Path $testModulePath, $locale) } | Should be $true
            { Test-Path (Merge-Path $testModulePath, $locale, "about_$testName.help.txt") } | Should be $true
            { Test-Path (Merge-Path $testModulePath, "Private") } | Should be $true
            { Test-Path (Merge-Path $testModulePath, "Public") } | Should be $true
            { Test-Path (Merge-Path $testModulePath, "$testName.psd1") } | Should be $true
            { Test-Path (Merge-Path $testModulePath, "$testName.psm1") } | Should be $true
            { Test-Path (Merge-Path $testFunctionPath) } | Should be $true
            { Test-Path (Merge-Path $testFunctionPath, "Private") } | Should be $true
            { Test-Path (Merge-Path $testFunctionPath, "Public") } | Should be $true

            Remove-Item $testProjectPath -Recurse -Force
        }

        It "Should create the project in the current directory if '.' is specified" {
            Set-Location $testPath

            New-PSModule -Name $testName -Path "." -Author 'Test' -Description 'Test'

            Set-Location $begin

            { Test-Path (Merge-Path $testProjectPath) } | Should be $true
            { Test-Path (Merge-Path $testProjectPath, "README.md") } | Should Be $true
            { Test-Path (Merge-Path $testModulePath) } | Should be $true
            { Test-Path (Merge-Path $testModulePath, $locale) } | Should be $true
            { Test-Path (Merge-Path $testModulePath, $locale, "about_$testName.help.txt") } | Should be $true
            { Test-Path (Merge-Path $testModulePath, "Private") } | Should be $true
            { Test-Path (Merge-Path $testModulePath, "Public") } | Should be $true
            { Test-Path (Merge-Path $testModulePath, "$testName.psd1") } | Should be $true
            { Test-Path (Merge-Path $testModulePath, "$testName.psm1") } | Should be $true
            { Test-Path (Merge-Path $testFunctionPath) } | Should be $true
            { Test-Path (Merge-Path $testFunctionPath, "Private") } | Should be $true
            { Test-Path (Merge-Path $testFunctionPath, "Public") } | Should be $true

            Remove-Item $testProjectPath -Recurse -Force
        }

        It "Should create the project with a build pipeline if switch is used" {
            Set-Location $testPath

            New-PSModule -Name $testName -Path $testPath -Author 'Test' -Description 'Test' -BuildPipeline

            Set-Location $begin

            # Default paths
            { Test-Path (Merge-Path $testProjectPath) } | Should be $true
            { Test-Path (Merge-Path $testProjectPath, "README.md") } | Should Be $true
            { Test-Path (Merge-Path $testModulePath) } | Should be $true
            { Test-Path (Merge-Path $testModulePath, $locale) } | Should be $true
            { Test-Path (Merge-Path $testModulePath, $locale, "about_$testName.help.txt") } | Should be $true
            { Test-Path (Merge-Path $testModulePath, "Private") } | Should be $true
            { Test-Path (Merge-Path $testModulePath, "Public") } | Should be $true
            { Test-Path (Merge-Path $testModulePath, "$testName.psd1") } | Should be $true
            { Test-Path (Merge-Path $testModulePath, "$testName.psm1") } | Should be $true
            { Test-Path (Merge-Path $testFunctionPath) } | Should be $true
            { Test-Path (Merge-Path $testFunctionPath, "Private") } | Should be $true
            { Test-Path (Merge-Path $testFunctionPath, "Public") } | Should be $true

            # Build-pipeline specific paths
            { Test-Path (Merge-Path $testModulePath, "build_utils.ps1") } | Should Be $true
            { Test-Path (Merge-Path $testModulePath, "$testName.build.ps1") } | Should Be $true
            { Test-Path (Merge-Path $testModulePath, "$testName.settings.ps1") } | Should Be $true
            { Test-Path (Merge-Path $testModulePath, ".gitignore") } | Should Be $true

            Remove-Item $testProjectPath -Recurse -Force
        }
    }
}

Remove-Module PSScaffold -Force
