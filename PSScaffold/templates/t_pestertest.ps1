$PesterFileContent = @"
`$here = (Split-Path -Parent `$MyInvocation.MyCommand.Path).Replace((Join-Path "Tests" <scope>), (Join-Path <module> <scope>))
`$sut = (Split-Path -Leaf `$MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

. (Join-Path `$here `$sut)

# To make test runable from project root, and from test directory itself. Do quick validation.
`$testsPath = Join-Path "Tests" "<scope>"
if ((Get-Location).Path -match "`$testsPath") {
    `$psmPath = (Resolve-Path "..\..\<module>\<module>.psm1").Path    
} else {
    `$psmPath = (Resolve-Path ".\<module>\<module>.psm1").Path
}

Import-Module `$psmPath -Force -NoClobber

InModuleScope "<module>" {

    Describe "<name>" {

    }

}
"@