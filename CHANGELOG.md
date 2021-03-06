# Changelog

### v2.1.0

Some major bugfixes for making the module more compatible with more operating systems (MacOS, Linux).

* Functions have received a overhaul for checking module path (OS agnostic).
* Functions have received overhauls regarding path checking (OS agnostic) for files and output.

### v2.0.0

* Module has been tested and confirmed to work with PowerShell 6.1.0 along side PowerShell for Windows.
* Changed `New-PSModule` to default to module version 0.1.0 in creation of a new module.
* Changed some formatting in the sources.
* Added `Publish-PSModule` to generated `build_utils.ps1` (`t_build.ps1`). This to make builds non-dependent on `PSScaffold`.
* Removed function `Install-PSAzureVMModule` since it was quite specific and probably not used. It might return in the form of `Install-PSModuleToAzVM` in future versions.
* Removed function `Install-PSModuleInstallScript` sincei it was highly coupled to `Install-PSAzureVMModule`. Might return in an updated form in future versions.

### v1.1.5

* Removed folder en-US to fully remove the support for updatable help. Unfortunately this could not be tested locally as long as older versions of the 
module existed on the system. Build and deploy process will be looked into to further avoid a lot of version numbers.

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