<#
.SYNOPSIS
    A function to install PowerShell Modules from a custom PS Repository on an Azure ARM Virtual Machine.
.DESCRIPTION
    A function to isntall PowerShell Modules from a custom PS Repository on an Azure ARM Virtual Machine.
    Assuming that some form of PowerShell Repository is available and has modules.

    See: https://urltoinstructions.
.PARAMETER Name
    <String> The name of the module. To be used in Script generation and to keep track of what names to be used when deploying.
.PARAMETER SubscriptionId
    <String> The GUID of an Azure Subscription.
.PARAMETER ResourceGroupName
    <String> The name of the Resource Group that the Virtual Machine is part of.
.PARAMETER VMName
    <String> The name of the Virtual Machine.
.PARAMETER FileName
    <String> The name of the installation script file. Used to keep track when generating install script, or what the existing script is
    named on the Storage Account.
.PARAMETER Argument
    <String> Additional arguments. If an installl script takes arguments, specify them as a string.
    $arguments = "-User username -Group group"
    
    If it's an array

    $arguments = "-User user1,user2 -Group group"

.PARAMETER StorageAccountName
    <String> The name of the Storage Account that will contain the script.
.PARAMETER Container
    <String> The container where the script will be located. Used together with 'StorageAccountName'.
.PARAMETER RepositoryName
    <String> The name of the Repository. Used in combination with 'UploadScript' so it can determine on what PSRepository
    to use.
.PARAMETER RepositoryPath
    <String> The path to the Repository. Used in combination with 'UploadScript' so it can determine on what PSRepository
    path to use.
.PARAMETER UploadScript
    <Switch> This parameter is used so an install script can be generated during runtime. The script will be generated and uploaded.
    It will need 'StorageAccountName', 'Container', 'RepositoryName' and 'RepositoryPath' to be correct.
.PARAMETER FileUrl
    <String> A URI to a script file in raw format. It is stand alone and should not be used with the parameters that are
    associated with StorageAccount and Repository.
.NOTES
    Written by Karl Wallenius, Redeploy AB.
#>
function Install-PSAzureVMModule {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [String]
        $Name,
        [Parameter(Mandatory = $true, Position = 1)]
        [String]
        $SubscriptionId,
        [Parameter(Mandatory = $true, Position = 2)]
        [String]
        $ResourceGroupName,
        [Parameter(Mandatory = $true, Position = 3)]
        [String]
        $VMName,
        [Parameter(Mandatory = $true, Position = 4)]
        [String]
        $FileName,
        [Parameter(Mandatory = $false)]
        [String]
        $Argument,
        [Parameter(Mandatory = $false, ParameterSetName = "StorageAccount")]
        [String]
        $StorageAccountName,
        [Parameter(Mandatory = $false, ParameterSetName = "StorageAccount")]
        [String]
        $Container,
        [Parameter(Mandatory = $false, ParameterSetName = "StorageAccount")]
        [String]
        $RepositoryName,
        [Parameter(Mandatory = $false, ParameterSetName = "StorageAccount")]
        [String]
        $RepositoryPath,
        [Parameter(Mandatory = $false, ParameterSetName = "StorageAccount")]
        [switch]
        $UploadScript = $false,
        [Parameter(Mandatory = $false, ParameterSetName = "FileUri")]
        [String]
        $FileUri
    )

    process {
        # Check if user is logged on.
        $loggedOn = $false
        $storageAccount = $false
        $uri = $false

        $extensionName = 'InstallModulesFromBuild'

        if ([string]::IsNullOrEmpty($StorageAccountName) -and [string]::IsNullOrEmpty($FileUri)) {
            
            throw 'You must specify either specify StorageAccount/Container or a FileUri'

        } elseif (-not [String]::IsNullOrEmpty($StorageAccountName)) {
            
            if ([String]::IsNullOrEmpty($Container)) {
                throw 'Storage Account selected, but no Container specified.'
            } else {
                $storageAccount = $true
            }

        } elseif (-not [string]::IsNullOrEmpty($FileUri)) {
            
            $uri = $true
        }

        Write-Verbose("Checking that a session to Azure exists.")
        try {
            [void](Get-AzureRmContext)
            $loggedOn = $true
        } catch [System.Exception] {
            $loggedOn = $false
        }

        if (!($loggedOn)) {
            Write-Verbose("No current session to Azure. Prompting for login.")
            $login = Login-AzureRmAccount
            if ($login -eq $null) {
                throw 'User authentication failed.'
            }
        }

        # Try to select the Azure Subscription
        try {
            [void](Select-AzureRmSubscription -SubscriptionId $SubscriptionId)
        } catch [System.Exception] {
            throw($_.Exception)
        }

        # Get Azure VM.
        $vm = $null
        try {
            $vm = Get-AzureRmVM -ResourceGroupName $ResourceGroupName -Name $VMName -InformationAction Ignore
        } catch [System.Exception] {
            throw($_.Exception)
        }
    
        # Common parameters.
        $runParams = @{
            Name = $extensionName
            ResourceGroupName = $vm.ResourceGroupName
            VMName = $vm.Name
            Location = $vm.Location
            Run = $FileName
        }

        if ($storageAccount) {
            Write-Verbose("Storage Account selected as medium for script file.")
            # If Storage Account, get the Key.
            try {
                $key = (Get-AzureRmStorageAccountKey -ResourceGroupName $ResourceGroupName -Name $StorageAccountName).Value[0]
            } catch [System.Exception] {
                throw($_.Exception)
            }
    
            $runParams.StorageAccountName = $StorageAccountName
            $runParams.StorageAccountKey = $key
            $runParams.Container = $Container
            $runParams.FileName = $FileName

            if ($UploadScript) {
                Write-Verbose("Generating install script and uploading to Storage Account: {0}" -f $StorageAccountName)
                # Code to generate and upload script.
                $blobName = $FileName
                $scriptPath = Join-Path $env:TEMP $blobName

                New-PSModuleInstallScript `
                    -RepositoryName $RepositoryName `
                    -RepositoryPath $RepositoryPath `
                    -Module $Name `
                    -OutputPath $scriptPath `
                    -StorageAccountName $StorageAccountName `
                    -StorageAccountKey $key

                $stgContext = New-AzureStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $key
                $upload = Set-AzureStorageBlobContent -File $scriptPath -Container $Container -Blob $blobName -Context $stgContext -Force
                # Remove files from temp and blob storage.
                [void](Remove-Item -Path $scriptPath -Force)
            }
        }

        if ($uri) {
            Write-Verbose("File Uri selected as medium for script file.")
            $runParams.FileUri = $fileUri
        }

        # Check arguments to install script.
        if (-not [String]::IsNullOrEmpty($Argument)) {
            # Argument validation.
            Write-Verbose("Arguments specified: {0}" -f $Argument)
            $runParams.Argument = $Argument
        }

        # Predefine result object, this so it can be asserted by build steps.
        $result = [PSCustomObject]@{
            'Status' = $null
            'Message' = $null
        }
        
        Write-Verbose("Setting CustomScriptExtension: {0}" -f $extensionName)
        try {
            $install = Set-AzureRmVMCustomScriptExtension @runParams -ErrorAction Stop

            $result.Status = $install.StatusCode
            $result.Message = 'Modules where installed without errors.'
        } catch {
            $result.Status = 'Error'
            $result.Message = 'At least one Module failed installation. Please check logs on target server for more information.'
        }

        Write-Verbose("Removing CustomScriptExtension: {0}" -f $extensionName)
        try {
            $remove = Remove-AzureRmVMCustomScriptExtension -ResourceGroupName $vm.ResourceGroupName -VMName $vm.Name -Name $extensionName -Force -ErrorAction Stop
        } catch [System.Exception] {
            $result.Message = 'Modules where installed, but CustomScriptExtension could not be removed.'
        }

        if ($UploadScript) {
            Write-Verbose("Removing install script from Storage Account: {0}" -f $StorageAccountName)
            $removeBlob = Remove-AzureStorageBlob -Blob $blobName -Container $Container -Context $stgContext -Force
        }

        $result
    }
}