#
# Module manifest for module 'PSScaffold'
#
# Generated by: Karl Wallenius
#
# Generated on: 2017-05-04
#

@{

# Script module or binary module file associated with this manifest.
RootModule = 'PSScaffold.psm1'

# Version number of this module.
ModuleVersion = '1.0.1'

# Supported PSEditions
# CompatiblePSEditions = @()

# ID used to uniquely identify this module
GUID = 'c2eda2a1-4fb8-4728-9600-df2508f79dea'

# Author of this module
Author = 'Karl Wallenius, Redeploy'

# Company or vendor of this module
CompanyName = 'Redeploy AB'

# Copyright statement for this module
Copyright = '(c) 2017 Redeploy AB. All rights reserved.'

# Description of the functionality provided by this module
Description = 'A module that contains functions to scaffold PowerShell module structures, new functions and Pester tests. Also some tools for deployment of the modules to Azure and generating install scripts. See the GitHub Repository for more information.'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '3.0'

# Name of the Windows PowerShell host required by this module
# PowerShellHostName = ''

# Minimum version of the Windows PowerShell host required by this module
# PowerShellHostVersion = ''

# Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# DotNetFrameworkVersion = ''

# Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# CLRVersion = ''

# Processor architecture (None, X86, Amd64) required by this module
# ProcessorArchitecture = ''

# Modules that must be imported into the global environment prior to importing this module
# RequiredModules = @()

# Assemblies that must be loaded prior to importing this module
# RequiredAssemblies = @()

# Script files (.ps1) that are run in the caller's environment prior to importing this module.
# ScriptsToProcess = @()

# Type files (.ps1xml) to be loaded when importing this module
# TypesToProcess = @()

# Format files (.ps1xml) to be loaded when importing this module
# FormatsToProcess = @()

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
# NestedModules = @()

# Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
FunctionsToExport = 'Install-PSAzureVMModule','New-PSBuildPipeline','New-PSFunction','New-PSModule','New-PSModuleInstallScript','New-PSPesterTest'

# Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
CmdletsToExport = '*'

# Variables to export from this module
VariablesToExport = '*'

# Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
AliasesToExport = '*'

# DSC resources to export from this module
# DscResourcesToExport = @()

# List of all modules packaged with this module
# ModuleList = @()

# List of all files packaged with this module
# FileList = @()

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = @('scaffold', 'template', 'build', 'test')

        # A URL to the license for this module.
        LicenseUri = 'https://github.com/RedeployAB/PSScaffold/blob/master/LICENSE'

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/RedeployAB/PSScaffold'

        # A URL to an icon representing this module.
        # IconUri = ''

        # ReleaseNotes of this module
        ReleaseNotes = 'https://github.com/RedeployAB/PSScaffold/blob/master/README.md#version'

    } # End of PSData hashtable

} # End of PrivateData hashtable

# HelpInfo URI of this module
HelpInfoURI = 'https://github.com/RedeployAB/PSScaffold#usage'

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}

