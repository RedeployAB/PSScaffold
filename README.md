# PSScaffold
This module contains functions to scaffold the structures of PowerShell modules and build pipelines.

The structure of the resulting module file structure is inspired by:
[Rambling Cookie Monster's blog post](http://ramblingcookiemonster.github.io/Building-A-PowerShell-Module/)

The build pipeline, tasks and structure was inspired by (and the contents of `build_utils.ps1`):
[xainey/Michael Willis blog post](https://xainey.github.io/2017/powershell-module-pipeline/)

Michael Willis is also responsible for the module `PSTestReport` that the build process downloads during it's build process.

We've consolidated this to four functions that creates the needed files in a good and easy to understand
file structure.

Using [Azure File Storage](https://redeploy.se/azure-file-share-ps-module-repository/) as a module repository. It's of course possibly to deploy to other repositories. Change the Publish task in `ModuleName.build.ps1`, and write a deploy/publish function and add it to `build_utils.ps1`.


**Content**

* [Introduction](#introduction)
* [Installation](#installation)
* [Functions](#functions)
  * [Public functions](#public-functions)
  * [Private functions](#private-functions)
* [Usage Examples](#usage-examples)

## Introduction

**Prerequisites**

It's strongly recommended that you have the following PowerShell modules installed:

* InvokeBuild
* Pester
* PSScriptAnalyzer
* PSTestReport (downloaded from Xainyes GitHub during build)

**InvokeBuild** is used as a task runner, and runs the entire build and eventual deploy process. It's needed to run the build. **PSSCriptAnalyzer** provides functions to analyze and recommend changes to your code. **Pester** (included in newer versions of PowerShell) is the testing framework of choice for many PowerShell developers.

For more information about PowerShell Module structure:
[Rambling Cookie Monsters take on PowerShell modules](http://ramblingcookiemonster.github.io/Building-A-PowerShell-Module/)

For more information about the PowerShell Build Pipeline and how to use it:
[Michael Willis@xaines great article](https://xainey.github.io/2017/powershell-module-pipeline/)

To get started with unit testing with Pester (a very big subject in itself):
[PowerShell Magazines introduction](http://www.powershellmagazine.com/2014/03/12/get-started-with-pester-powershell-unit-testing-framework/)

To make best use of `New-PSModuleInstallScript` and `Install-PSAzureVMModule` i really recommend to
make them part of the build process to deploy them to the server when the build finishes and is successful.

## Installation

From the PowerShell Gallery:

`Install-Module -Name PSScaffold`

From GitHub:

Download the project and copy the module directory to a `Modules` directory that is included in `PSModulePath`.

To include it in other projects incorporate this in the module functions:

`Import-Module PSScaffold`


## Functions

### Public functions

**`New-PSBuildPipeline`**

Scaffolds settings and scripts for a build process.

| Param    | Type     | Mandatory | Allowed Values      |                                                                |
|----------|----------|-----------|---------------------|----------------------------------------------------------------|
| `Module` | *String* | True      |                     | The path to a Module.                                          |

It will add some files to the module project directory. The updated structure will look like:

```
- ModuleName
-- ModuleName
--- en-US
---- about_ModuleName.help.txt
--- Private
--- Public
--- ModuleName.psd1
--- ModuleName.psm1
- .gitignore
- build_utils.ps1
- ModuleName.build.ps1
- ModuleName.settings.ps1
- README.md
```


**`New-PSFunction`**

Creates a new function file and scaffolds base structure, to the target module. If `Module` isn't specified, it assumes
that the command prompt is in the root directory of the project. 

| Param        | Type     | Mandatory | Allowed Values      |                                                                |
|--------------|----------|-----------|---------------------|----------------------------------------------------------------|
| `Name`       | *String* | True      |                     | The name of the function to create.                            |
| `Module`     | *String* | False     |                     | The path to the module project root directory.                 |
| `Scope`      | *String* | False     | *Private*, *Public* | The scope of the function. Allowed values: Private and Public. Default: Public. |
| `PesterTest` | *Switch* | False     |                     | If used, a Pester Test file will be created in the module      |


**`New-PSModule`**

Function to initialize and scaffolc the structure for a PowerShell script/function module. If no path is specified. It's
created at your current location in the file system.

| Param           | Type     | Mandatory | Allowed Values |                                                                      |
|-----------------|----------|-----------|----------------|----------------------------------------------------------------------|
| `Name`          | *String* | True      |                | The name of the module.                                              |
| `Path`          | *String* | False     |                | Path to where the module should be created.                          |
| `Author`        | *String* | True      |                | Name of the author.                                                  |
| `Description`   | *String* | False     |                | Description of the module.                                           |
| `BuildPipeline` | *Switch* | False     |                | Adds a build pipeline inside the function with `New-PSBuildPipeline` |



It will create the following folders and files.

```
- ModuleName
-- ModuleName
--- en-US
---- about_ModuleName.help.txt
--- Private
--- Public
-- ModuleName.psd1
-- ModuleName.psm1
```


**`New-PSPesterTest`**

Function to scaffold the structure of a test file for Pester tests.

| Param        | Type     | Mandatory | Allowed Values      |                                                                |
|--------------|----------|-----------|---------------------|----------------------------------------------------------------|
| `Name`       | *String* | True      |                     | The name of the function to create a test for.                 |
| `Module`     | *String* | True      |                     | The path to the module project root directory.                 |
| `Scope`      | *String* | False     | *Private*, *Public* | The scope of the function. Allowed values: Private and Public. Default: Public. |


**`Publish-PSModule`**

This function is used to publish a module (after verifying and incrementing the version number with the repository) repository.
NuGet and SMB share is supported.
 
| Param            | Type     | Mandatory | Allowed Values      |                                          |
|------------------|----------|-----------|---------------------|------------------------------------------|
| `RepositoryName` | *String* | True      |                     | Name of the module repository.           |
| `RepositoryPath` | *String* | False     |                     | Path to repository (**\\path\to\repo**). |
| `ApiKey`         | *String* | False     |                     | NuGet API key.                           |
| `ModuleName`     | *String* | True      |                     | Name of the module to publish.           |
| `ModulePath`     | *String* | True      |                     | Path to the modules manifest (`.psd1`).  |
| `BuildNumber`    | *Int32*  | True      |                     | Number of the build.                     |


### Private functions

**`Get-ModulePath`**

If a relative/provided path is valid, it is cleaned and returned. If the current
path (.) is provided it is resolved and returned. Is there no path
provided, the current location is returned.

| Param  | Type     | Mandatory | Allowed Values      |                                          |
|--------|----------|-----------|---------------------|------------------------------------------|
| `Path` | *String* | False     |                     | Name of the module repository.           |


**`Merge-Path`**

Takes one or more strings as an array and merges them into a single path
with the help of [System.IO.Path]::Combine().

Same result can be achieved with Join-Path in PS 6.0 and above, but this
lets us be backwards compatible.

| Param  | Type     | Mandatory | Allowed Values      |                                  |
|--------|----------|-----------|---------------------|----------------------------------|
| `Path` | *String* | True      |                     | Array of paths/strings to merge. |


## Usage Examples

**New-PSModule**

To create a module, in your documents folder:

```
cd ~\Documents\Projects
New-PSModule -Name PSTools -Author 'Person'

# Or

New-PSModule -Name PSTools -Path C:\Users\UserA\Documents\Projects -Author 'Person' -Description 'A tool set'

# Or

New-PSModule PSTools . Person
```

All these examples create the PowerShell Module directory structure in the directory:
`C:\Users\UserA\Documents\Projects\PSTools`.

If you want to add the Build Pipline at the project creation. Use the switch `-BuildPipeline` like so:

`New-PSModule -Name PSTools -Author 'Person' -BuildPipeline`

It works with all the examples shown above.


**New-PSBuildPipeline**

To create the needed files for a build pipeline:

```
cd ~\Documents\Projects\ExistingModule
New-PSBuildPipeline

# Or

cd ~\Documents\Projects\ExistingModule
New-PSBuildPipeline .

# Or

New-PSBuildpipeline -Module C:\Users\UserA\Documents\Projects\ExistingModule
```

Don't forget to modify `ModuleName.settings.ps1` to meet your deployment needs. Also 
take a glance at `ModuleName.build.ps1` to see if the build process is to your satisfaction.

**New-PSFunction**

To create a new function (can of course be done manually, or through your IDE if it supports extension):

```
cd ~\Documents\Projects\ExistingModule
New-PSFunction -Name Get-Stuff 

# Or

cd ~\Documents\Projects\ExistingModule
New-PSFunction -Name Get-Stuff .

# Or

New-PSFunction -Name Get-Stuff -Module C:\Users\UserA\Documents\Projects\ExistingModule

# To also create a Pester test file for the function

New-PSFunction -Name Get-Stuff -PesterTest
```

The function takes a parameter `Scope` that allows `Public` and `Private`.
This will determine what subdirectory the new function will be placed (also the test file in the test subdirectory structure).

Functions in the `Public` scope is exposed and available when the module is imported. `Private` is supposed for internal
helper functions that your `Public` functions uses. The `.psm1` file act as a loader that loads and exposes the functions.


**New-PSPesterTest**

To create a new Pester test for a function (can of course be done manually, or through your IDE if it supports extension):

```
cd ~\Documents\Projects\ExistingModule
New-PSPesterTest -Name Get-Stuff 

# Or

cd ~\Documents\Projects\ExistingModule
New-PSPesterTest -Name Get-Stuff .

# Or

New-PSPesterTest -Name Get-Stuff -Module C:\Users\UserA\Documents\Projects\ExistingModule
```

The function takes a parameter `Scope` that allows `Public` and `Private`.
This will determine what subdirectory the new function will be placed