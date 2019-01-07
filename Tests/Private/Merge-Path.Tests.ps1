$here = (Split-Path -Parent $MyInvocation.MyCommand.Path).Replace((Join-Path "Tests" "Private"), (Join-Path "PSScaffold" "Private"))
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

. (Join-Path $here $sut)

Import-Module (Resolve-Path .\PSScaffold\PSScaffold.psm1) -Force -NoClobber

InModuleScope "PSScaffold" {

    Describe "Merge-Path" {
        It "Should merge two paths into a single path" {
            $testPaths = "Directory A", "Directory B"

            Test-Path (Merge-Path $testPaths) -IsValid | Should Be $true
        }

        It "Should merge four paths into a single path" {
            $testPaths = "Directory A", "Directory B", "Directory C", "Directory D"

            Test-Path (Merge-Path $testPaths) -IsValid | Should Be $true
        }

        It "Should throw when given an empty parameter" {
            $testPaths = ""

            { Merge-Path $testPaths } | Should throw
        }

        It "Should throw when given a null parameter" {
            $testPaths = $null

            { Merge-Path $testPaths } | Should throw
        }

        It "Should only accept one parameter" {
            $getParameters = @{
                Path = @("Path A", "Path B")
                InvalidParameter = $null
            }

            { Merge-Path @getParameters } | Should throw
        }
    }

}
