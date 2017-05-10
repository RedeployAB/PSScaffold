# PSScaffold
This module contains functions to scaffold the structures of PowerShell modules and build pipelines.

The structure of the resulting module file structure is inspired by:
[Rambling Cookie Monster's blog post](http://ramblingcookiemonster.github.io/Building-A-PowerShell-Module/)

The build pipeline was inspired by:
[xainey/Michael Willis blog post](https://xainey.github.io/2017/powershell-module-pipeline/)

We've consolidated this to four functions that creates the needed files in a good and easy to understand
file structure.

Some tools to deploy the scripts have also been included into the module.

**Content**

* [Installation](#install)
* [Functions](#functions)
* [Usage Examples](#usage)
* [Versions and Updates](#version)

## <a name=install>Installation</a>

Copy the module directory to a `Modules` directory that is included in `PSModulePath`.

To include it in other projects incorporate this in the module functions:

`Import-Module PSScaffold`


## <a name="functions">Functions</a>

### Public functions

**`Install-PSAzureVMModule`**

This function is used to deploy a module on an Azure VM. For this function to work an installation script must exist.
Either an installation script can be located in an Azure Storage account, or directly through an URI.

Use the switch `UploadScript` to generate an upload script that is uploaded to the specified Storage Account. Otherwise
you will have to generate this manually, and upload it to the specified container, before using `Install-PSAzureVMModule`.

| Param                | Type     | Mandatory | Allowed Values |                                                                 |
|----------------------|----------|-----------|----------------|-----------------------------------------------------------------|
| `Name`               | *String* | True      |                | Name of the module.                                             |
| `SubscriptionId`     | *String* | True      |                | The GUID of the Subscription on where the VM resides.           |
| `ResourceGroupName`  | *String* | True      |                | Name of the Resource Group of the VM.                           |
| `VMName`             | *String* | True      |                | Name of the VM.                                                 |
| `FileName`           | *String* | True      |                | Name if the installation script.                                |
| `Argument`           | *String* | False     |                | Arguments to the script.                                        |
| `StorageAccountName` | *String* | False     |                | Name of Storage Account where installation script is located.   |
| `Container`          | *String* | False     |                | Name of container where installation script is located.         |
| `UploadScript`       | *Switch* | False     |                | Switch to determine if script should be generated and uploaded. |
| `RepositoryName`     | *String* | False     |                | Used with the `UploadScript` switch. Used for script generation. |
| `RepositoryPath`     | *String* | False     |                | Used with the `UploadScript` switch. Used for script generation.
| `FileUri`            | *String* | False     |                | URI to the installation script.                                 |


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

**`New-PSModuleInstallScript`**

Function to generate a module installation script. At this writing it only supports scripts targeted at Repositories that
are made available through `Register-PSRepository`. This might change in a future release.

If `StorageAccountName` is left empty. It will not add the mapping of the network drive inside the script. This is 
usefule if you just want to generate a script template and modify it afterwards.

| Param                | Type     | Mandatory | Allowed Values |                                                               |
|----------------------|----------|-----------|----------------|---------------------------------------------------------------|
| `RepositoryName`     | *String* | True      |                | The name of the PowerShell repository.                        |
| `RepositoryPath`     | *String* | True      |                | The path to the PowerShell repository.                        |
| `Module`             | *String* | True      |                | Name of the Module.                                           |
| `OutputPath`         | *String* | False     |                | Output path of the script. If no parameter is given, it defaults to the current path with name `install-module.ps1 |
| `StorageAccountName` | *String* | False     |                | Used for adding net drive mapping to the install script.      |
| `StorageAccountKey`  | *String* | False     |                | Used for adding net drive mapping to the install script.      |


**`New-PSPesterTest`**

Function to scaffold the structure of a test file for Pester tests.

| Param        | Type     | Mandatory | Allowed Values      |                                                                |
|--------------|----------|-----------|---------------------|----------------------------------------------------------------|
| `Name`       | *String* | True      |                     | The name of the function to create a test for.                 |
| `Module`     | *String* | True      |                     | The path to the module project root directory.                 |
| `Scope`      | *String* | False     | *Private*, *Public* | The scope of the function. Allowed values: Private and Public. Default: Public. |


## <a name=usage>Usage Examples</a>

To create a module, in your documents folder

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

## <a name=version>Versions and Updates</a>

### v1.0.0

* First release.