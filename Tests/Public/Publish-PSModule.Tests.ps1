$here = (Split-Path -Parent $MyInvocation.MyCommand.Path).Replace((Join-Path "Tests" "Public"), (Join-Path "PSScaffold" "Public"))
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

. (Join-Path $here $sut)

Import-Module (Resolve-Path .\PSScaffold\PSScaffold.psm1) -Force -NoClobber

InModuleScope "PSScaffold" {

    Describe "Publish-PSModule" {

        Mock Register-PSRepository { }

        $testPath = (Merge-Path ([IO.Path]::GetTempPath()), "ModuleFolder")
        $testName = "TestModule"
        $testModulePath = (Merge-Path $testPath, $testName, $testName)
        New-Item -ItemType Directory -Path $testPath

        New-PSModule -Name $testName -Path $testPath -Author 'Test' -Description 'Test'

        It "Should publish the module to a repository." {

            Mock Get-PSRepository { return @{
                Name = $RepositoryName
            }}

            Mock Test-Path { return $true }

            Mock Find-Module { return $false }

            Mock Publish-Module { }

            $publishParams = @{
                RepositoryName = 'TestRepo'
                RepositoryPath = '\\path\to\repo'
                ModuleName = $testName
                ModulePath = (Merge-Path $testModulePath, "TestModule.psd1")
                BuildNumber = 1
            }

            { Publish-PSModule @publishParams } | Should Not throw
        }

        It "Should publish the module to a repository and update it's module manifest." {

            Mock Get-PSRepository { return @{
                Name = $RepositoryName
            }}

            Mock Test-Path { return $true }

            Mock Find-Module { return $true }

            Mock Publish-Module { }

            $publishParams = @{
                RepositoryName = 'TestRepo'
                RepositoryPath = '\\path\to\repo'
                ModuleName = $testName
                ModulePath = (Merge-Path $testModulePath, "TestModule.psd1")
                BuildNumber = 1
            }

            { Publish-PSModule @publishParams } | Should Not throw

            $moduleVersion = (Get-Content (Merge-Path $testModulePath, "TestModule.psd1") | select-string ".*ModuleVersion.*") -replace "\s" -replace "\w*=" -replace "'"

            $moduleVersion | Should Be "0.1.1"
        }

        It "Should publish the module to a repository and update it's module manifest, with added properties." {

            Mock Get-PSRepository { return @{
                Name = $RepositoryName
            }}

            Mock Test-Path { return $true }

            Mock Find-Module { return $true }

            Mock Publish-Module { }

            $publishParams = @{
                RepositoryName = 'TestRepo'
                RepositoryPath = '\\path\to\repo'
                ModuleName = $testName
                ModulePath = (Merge-Path $testModulePath, "TestModule.psd1")
                BuildNumber = 1
                Properties = @{
                    ReleaseNotes = "Release Notes."
                    Tags = @('Tag1', 'Tag2')
                    LicenseUri = "https://licenseuri"
                    IconUri = "https://iconuri"
                    ProjectUri = "https://projecturi"
                }
            }

            { Publish-PSModule @publishParams } | Should Not throw

            $moduleVersion = (Get-Content (Merge-Path $testModulePath, "TestModule.psd1") | select-string ".*ModuleVersion.*") -replace "\s" -replace "\w*=" -replace "'"

            $moduleVersion | Should Be "0.1.1"
        }

        It "Should publish the module to a repository and update it's module manifest, and split 'Tags' property if it's a string and comma seperated." {

            Mock Get-PSRepository { return @{
                Name = $RepositoryName
            }}

            Mock Test-Path { return $true }

            Mock Find-Module { return $true }

            Mock Publish-Module { }

            $publishParams = @{
                RepositoryName = 'TestRepo'
                RepositoryPath = '\\path\to\repo'
                ModuleName = $testName
                ModulePath = (Merge-Path $testModulePath, "TestModule.psd1")
                BuildNumber = 1
                Properties = @{
                    Tags = 'Tag1,Tag2'
                }
            }

            { Publish-PSModule @publishParams } | Should Not throw

            $moduleVersion = (Get-Content (Merge-Path $testModulePath, "TestModule.psd1") | select-string ".*ModuleVersion.*") -replace "\s" -replace "\w*=" -replace "'"

            $moduleVersion | Should Be "0.1.1"
        }

        It "Should publish the module to PSGallery with an API key." {
            Mock Get-PSRepository { return @{
                Name = $RepositoryName
            }}

            Mock Test-Path { return $true }

            Mock Find-Module { return $false }

            Mock Publish-Module { }

            $publishParams = @{
                RepositoryName = 'PSGallery'
                ApiKey = "ABCDEFGH"
                ModuleName = $testName
                ModulePath = (Merge-Path $testModulePath, "TestModule.psd1")
                BuildNumber = 1
            }

            { Publish-PSModule @publishParams } | Should Not throw
        }

        It "Should throw the module if PSGallery is specified without an API key." {
            Mock Get-PSRepository { return @{
                Name = $RepositoryName
            }}

            Mock Test-Path { return $true }

            Mock Find-Module { return $false }

            Mock Publish-Module { }

            $publishParams = @{
                RepositoryName = 'PSGallery'
                ModuleName = $testName
                ModulePath = (Merge-Path $testModulePath, "TestModule.psd1")
                BuildNumber = 1
            }

            { Publish-PSModule @publishParams } | Should throw
        }

        It "Should throw if it cannot find the target Repository Path if Repository is not registered" {
            Mock Get-PSRepository { return $false }

            Mock Test-Path { return $false }

            Mock Find-Module { return $false }

            Mock Publish-Module { }

            $publishParams = @{
                RepositoryName = 'TestRepo'
                RepositoryPath = '\\path\to\repo'
                ModuleName = $testName
                ModulePath = (Merge-Path $testModulePath, "TestModule.psd1")
                BuildNumber = 1
            }

            { Publish-PSModule @publishParams } | Should throw
        }

        It "Should register the repository if it's not registered and not 'PSGallery' is specified." {
            Mock Get-PSRepository { return $false }

            Mock Test-Path { return $true }

            Mock Find-Module { return $false }

            Mock Publish-Module { }

            $publishParams = @{
                RepositoryName = 'TestRepo'
                RepositoryPath = '\\path\to\repo'
                ModuleName = $testName
                ModulePath = (Merge-Path $testModulePath, "TestModule.psd1")
                BuildNumber = 1
            }

            { Publish-PSModule @publishParams } | Should not throw
        }

        It "Should throw if 'Publish-Module' fails" {
            Mock Get-PSRepository { return @{
                Name = $RepositoryName
            }}

            Mock Test-Path { return $true }

            Mock Find-Module { return $false }

            Mock Publish-Module { throw }

            Mock Register-PSRepository { }

            $publishParams = @{
                RepositoryName = 'TestRepo'
                RepositoryPath = '\\path\to\repo'
                ModuleName = $testName
                ModulePath = (Merge-Path $testModulePath, "TestModule.psd1")
                BuildNumber = 1
            }

            { Publish-PSModule @publishParams } | Should throw
        }

        Remove-Item -Path $testPath -Recurse -Force
    }

}

Remove-Module PSScaffold -Force
