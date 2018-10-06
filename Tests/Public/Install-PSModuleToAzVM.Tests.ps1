$here = (Split-Path -Parent $MyInvocation.MyCommand.Path).Replace("Tests\Public","PSScaffold\Public")
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

. "$here\$sut"

# To make test runable from project root, and from test directory itself. Do quick validation.
if ((Get-Location).Path -match "\\Tests\\Public") {
    $psmPath = (Resolve-Path "..\..\PSScaffold\PSScaffold.psm1").Path    
} else {
    $psmPath = (Resolve-Path ".\PSScaffold\PSScaffold.psm1").Path
}

Import-Module $psmPath -Force -NoClobber

InModuleScope "PSScaffold" {

    Describe "Install-PSModuleToAzVM" {

    }

}
