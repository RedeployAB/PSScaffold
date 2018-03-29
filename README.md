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

* [Introduction](#intro)
* [Installation](#install)
* [Functions](#functions)
* [Usage Examples](#usage)
* [Versions and Updates](#version)


## <a name=intro>Introduction</a>

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

## <a name=install>Installation</a>

From the PowerShell Gallery:

`Install-Module -Name PSScaffold`

From GitHub:

Download the project and copy the module directory to a `Modules` directory that is included in `PSModulePath`.

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

The script is supposed to be run on the target server, and do the necessary steps to install the module with
`Install-Module` from the specified **PSRepository** (which can very depending on your environment).

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


## <a name=usage>Usage Examples</a>

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

To create a new Pester tes for a function (can of course be done manually, or through your IDE if it supports extension):

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


**New-PSModuleInstallScript**

To generate install scripts:

```
# Generates a basic install script hat installs the module form a custom repository.

New-PSModuleInstallScript -RepositoryName CustomRepository -RepositoryPath \\path\to\repo -Module PSTools

# Generate a script that in the script also maps the network drive needed for the PSRepository
# that is located in an Azure File Share

New-PSModuleInstallScript -RepositoryName CustomRepository -RepositoryPath \\path\to\repo -Module PSTools -StorageAccountName customstorage -StorageAccountKey longkeystring 
```

**Install-AzureVMModule**

Installing a PowerShell module from your own localhost (or other machine) to a target
Azure Virtual Machine (ARM). This is best used when automated in a build script of sorts,
or in a task with `Invoke-Build`.

```
# To Install the module on the VM with an auto-generated installation script.

Install-PSAzureVMModule -Name PSTools -SubscriptionId GUID -ResorceGroupName rg1 -VMName vm1 -FileName install-pstools.ps1 -StorageAccountName customstorage -Container scripts -RepositoryName CustomRepository -RepositoryPath \\path\to\repo -UploadScript 

# Or more readable
$params = @{
    Name = "PSTools"
    SubscriptionId = "GUID"
    ResourceGroupName = "rg1"
    VMName = "vm1"
    FileName = "install-pstools.ps1"
    StorageAccountName = "customstorage"
    Container = "scripts"
    RepositoryName = "CustomRepository"
    RepositoryPath = "\\path\to\repo"
}

Install-PSAzureVMModule @params -UploadScript

# To install a module with an existing script file in the storage account.
$params = @{
    Name = "PSTools"
    SubscriptionId = "GUID"
    ResourceGroupName = "rg1"
    VMName = "vm1"
    FileName = "<existing-script-name>.ps1"
    StorageAccountName = "customstorage"
    Container = "scripts"
}

Install-PSAzureVMModule @params

# To install from a URI (HAS NOT BEEN VERIFIED YET)
$params = @{
    Name = "PSTools"
    SubscriptionId = "GUID"
    ResourceGroupName = "rg1"
    VMName = "vm1"
    FileName = "<existing-script-name>.ps1"
    FileUri = "http://urltofile/<existing-script-name>.ps1"
}

Install-PSAzureVMModule @params
```


## <a name=version>Versions and Updates</a>

### v1.1.4

* Removed support for updatable help.

### v1.1.3

* Fixed URI to HelpInfo.

### v1.1.2

* Added a template for a README.md when creating new modules with `New-PSModule`. Of course you may format your README in your own style. It's merely a suggestion.
* Minor bug fixes and enhancements.

### v1.1.1

* Added help text in function `Publish-PSModule`.
* Added task `Clean` to the pre-made `Test` task.
* Modified task `Clean` to check if `PSTestReport` is downloaded before cloning.

### v1.1.0

* Updated template for Pester-tests. Includes code snippet to Import it's own module from both root directory, and from the test files directory. The test can be run from root directory with `Invoke-Build` as
well as from the built-in test functionality from *Visual Studio Code* (which looks in the directory of the test file).

* Added `Publish-PSModule` found in `build_utils.ps1` as a function to the module.

### v1.0.3

* Fixed error in template for `build_utils.ps1`.

### v1.0.2

Some changes to the templates and initial scaffolding. The new `Publish-PSModule` might be moved from `build_utils.ps1` to be part of `PSScaffold` as a whole.
That is also why this is more of a fix than a minor version increment, since `PSScaffold` itself does not receive the function.

* Updated template for `build_utils.ps1`. The function `Publish-SMBModule` has been renamed to `Publish-PSModule` and has been reworked to support the official **PSGallery**.
* Updated template for `x.settings.ps1`. Most settings has been outcommented, to allow the user to customize more freely when modifying their build pipeline.

### v1.0.1

Changes to templates. Before/After hooks are now longer used by default. It's up
to the user and their needs if these needs to be implemented.

* Updated `t_build_settings.ps1` template. Commented out hooks.
* Updated `t_build.ps1` template. Removed Before/Afte hooks on templated tasks.

### v1.0.0

* First release.