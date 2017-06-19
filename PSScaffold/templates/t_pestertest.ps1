$PesterFileContent = @"
`$here = (Split-Path -Parent `$MyInvocation.MyCommand.Path).Replace("Tests\<scope>","<module>\<scope>")
`$sut = (Split-Path -Leaf `$MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

. "`$here\`$sut"

# To make test runable from project root, and from test directory itself. Do quick validation.
if ((Get-Location).Path -match "\\Tests\\<scope>") {
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