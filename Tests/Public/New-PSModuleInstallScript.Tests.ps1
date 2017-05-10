$here = (Split-Path -Parent $MyInvocation.MyCommand.Path).Replace("Tests\Public","PSScaffold\Public")
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

. "$here\$sut"

Import-Module (Resolve-Path .\PSScaffold\PSScaffold.psm1) -Force -NoClobber

InModuleScope "PSScaffold" {

    Describe "New-PSModuleInstallScript" {

        $repoName = "RedeployModules"
        $repoPath = "\\path\to\repo"
        $moduleName = "TestModule"

        New-Item -ItemType Directory -Path "$PSScriptRoot\..\..\artifacts\files"

        $filePath = (Resolve-Path "$PSScriptRoot\..\..\artifacts\files").Path

        It "Should generate the script in the current location if no output path is specified" {

            $params = @{
                RepositoryName = $repoName
                RepositoryPath = $repoPath
                Module = $moduleName
            }

            # Set path
            $filePath = (Resolve-Path "$PSScriptRoot\..\..\artifacts\files").Path

            # Get current location
            $currentLocation = (Get-Location).Path

            # Run the function from inside the artifacts directory.
            Set-Location $filePath
            New-PSModuleInstallScript @params
            Set-Location $currentLocation

            $fileExists = (Test-Path "$filePath\install-module.ps1")

            $fileExists | Should Be $true

        }

        It "Should generate the script at the specified location, without filename" {
            $params = @{
                RepositoryName = $repoName
                RepositoryPath = $repoPath
                Module = $moduleName
                OutputPath = $filePath  
            }

            New-PSModuleInstallScript @params

            $fileExists = (Test-Path "$filePath\install-$($moduleName.ToLower()).ps1")

            $fileExists | Should Be $true
        }

        It "Should generate the script at the specified location, with specified filename" {
            $params = @{
                RepositoryName = $repoName
                RepositoryPath = $repoPath
                Module = $moduleName
                OutputPath = "$filePath\new-script.ps1"  
            }

            New-PSModuleInstallScript @params

            $fileExists = (Test-Path "$filePath\new-script.ps1")

            $fileExists | Should Be $true
        }

        It "Should generate the script at the specified location, with specified filename and with SA Name and SA Key" {
            $params = @{
                RepositoryName = $repoName
                RepositoryPath = $repoPath
                Module = $moduleName
                OutputPath = "$filePath\new-script.ps1"
                StorageAccountName = 'TestName'
                StorageAccountKey = 'TestKey'  
            }

            New-PSModuleInstallScript @params

            $fileContent = Get-Content -Path "$filePath\new-script.ps1"
            $modified = $false
            if ($fileContent -match "net use") {
                $modified = $true
            }

            $fileExists = (Test-Path "$filePath\new-script.ps1")

            $fileExists | Should Be $true
            $modified | Should Be $true
        }    

        It "Should create the folder structure if it does not exist" {
            $newPath = Join-Path $filePath "subdir"

            $params = @{
                RepositoryName = $repoName
                RepositoryPath = $repoPath
                Module = $moduleName
                OutputPath = "$newPath\new-script.ps1"  
            }

            New-PSModuleInstallScript @params

            $fileExists = (Test-Path "$newPath\new-script.ps1")

            $fileExists | Should Be $true

            Remove-Item $filePath -Force -Recurse
        }

    }

}