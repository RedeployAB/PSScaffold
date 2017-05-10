$PesterFileContent = @"
`$here = (Split-Path -Parent `$MyInvocation.MyCommand.Path).Replace("Tests\<scope>","<module>\<scope>")
`$sut = (Split-Path -Leaf `$MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

. "`$here\`$sut"

Import-Module (Resolve-Path .\<module>\<module>.psm1) -Force -NoClobber

InModuleScope "<module>" {

    Describe "<name>" {

    }

}
"@