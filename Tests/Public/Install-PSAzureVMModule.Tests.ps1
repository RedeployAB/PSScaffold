$here = (Split-Path -Parent $MyInvocation.MyCommand.Path).Replace("Tests\Public", "PSScaffold\Public")
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

. "$here\$sut"

Import-Module (Resolve-Path .\PSScaffold\PSScaffold.psm1) -Force -NoClobber

InModuleScope "PSScaffold" {

    Describe "Install-PSAzureVMModule" {

        Mock Remove-AzureRmVMCustomScriptExtension { return $true }

        Context "User is not logged on" {
            # Since Get-AzureRmVm is hard to mock at the moment, I re-declare the function
            # with the expected reutrn values. It's ulgy. But it works.
            function Get-AzureRmVm {
                param(
                    $ResourceGroupName,
                    $Name 
                )
                return @{
                    ResourceGroupName = $ResourceGroupName
                    Name = $Name
                    Location = 'West Europe'
                }
            }

            Mock Get-AzureRmContext {
                throw 'Failed'
            }

            $params = @{
                Name = "TestModule"
                SubscriptionId = 'id'
                ResourceGroupName = 'rg1'
                VMName = 'vm1'
                FileName = 'file1.ps1'
                StorageAccountName = 'sto1'
                Container = 'scripts'
            }

            It "Should ask for user credentials if user is not logged on and throw if auth fails." {

                Mock Login-AzureRmAccount {
                    return $null
                }

                { Install-PSAzureVMModule @params } | Should throw                            
            }

            It "Should continue with it's actions if auth is successful" {
                Mock Login-AzureRmAccount {
                    return $true
                }

                Mock Select-AzureRmSubscription { 
                    return $true
                }

                Mock Get-AzureRmStorageAccountKey {
                    return @{ Value = @('longkey') }
                }

                Mock Set-AzureRmVMCustomScriptExtension {
                    return @{
                        'StatusCode' = 'OK'
                    }
                }

                $install = Install-PSAzureVMModule @params

                $install.Status | Should Be 'OK'
                $install.Message | Should Be 'Modules where installed without errors.'
            }
        }

        Context "User is logged on." {
            # Since Get-AzureRmVm is hard to mock at the moment, I re-declare the function
            # with the expected reutrn values. It's ulgy. But it works.
            function Get-AzureRmVm {
                param(
                    $ResourceGroupName,
                    $Name 
                )
                return @{
                    ResourceGroupName = $ResourceGroupName
                    Name = $Name
                    Location = 'West Europe'
                }
            }

            Mock Get-AzureRmContext {
                return $true
            }

            $params = @{
                Name = "TestModule"
                SubscriptionId = 'id'
                ResourceGroupName = 'rg1'
                VMName = 'vm1'
                FileName = 'file1.ps1'
                StorageAccountName = 'sto1'
                Container = 'scripts'
            }

            It "Should continue with it's actions if auth is successful" {
                Mock Login-AzureRmAccount {
                    return $true
                }

                Mock Select-AzureRmSubscription { 
                    return $true
                }

                Mock Get-AzureRmStorageAccountKey {
                    return @{ Value = @('longkey') }
                }

                Mock Set-AzureRmVMCustomScriptExtension {
                    return @{
                        'StatusCode' = 'OK'
                    }
                }

                $install = Install-PSAzureVMModule @params

                $install.Status | Should Be 'OK'
                $install.Message | Should Be 'Modules where installed without errors.'
            }
        }

        Context "Running of remote script" {

            # Since Get-AzureRmVm is hard to mock at the moment, I re-declare the function
            # with the expected reutrn values. It's ulgy. But it works.
            function Get-AzureRmVm {
                param(
                    $ResourceGroupName,
                    $Name 
                )
                return @{
                    ResourceGroupName = $ResourceGroupName
                    Name = $Name
                    Location = 'West Europe'
                }
            }

            Mock Get-AzureRmContext {
                return $true
            }

            Mock Login-AzureRmAccount {
                return $true
            }

            Mock Select-AzureRmSubscription { 
                return $true
            }

            Mock Get-AzureRmStorageAccountKey {
                return @{ Value = @('longkey') }
            }

            Mock Set-AzureRmVMCustomScriptExtension {
                return @{
                    'StatusCode' = 'OK'
                }
            }

            Mock Remove-AzureRmVMCustomScriptExtension {
                return @{
                    'StatusCode' = 'OK'
                }
            }


            It "Should throw if a Storage Account is specified but a container is not" {
                
                $params = @{
                    Name = "TestModule"
                    SubscriptionId = 'id'
                    ResourceGroupName = 'rg1'
                    VMName = 'vm1'
                    FileName = 'file1.ps1'
                    StorageAccountName = 'sto1'
                    Container = ''
                }

                { Install-PSAzureVMModule @params } | Should throw
                
            }

            It "Should succeed if a Storage Account is specified and a container is correct" {
                $params = @{
                    Name = "TestModule"
                    SubscriptionId = 'id'
                    ResourceGroupName = 'rg1'
                    VMName = 'vm1'
                    FileName = 'file1.ps1'
                    StorageAccountName = 'sto1'
                    Container = 'scripts'
                }

                $install = Install-PSAzureVMModule @params

                $install.Status | Should Be 'OK'
                $install.Message | Should Be 'Modules where installed without errors.'

            }

            It "Should use FileUri if that is specified" {
                $params = @{
                    Name = "TestModule"
                    SubscriptionId = 'id'
                    ResourceGroupName = 'rg1'
                    VMName = 'vm1'
                    FileName = 'file1.ps1'
                    FileUri = 'https://someuri.com/file.ps1'
                }

                $install = Install-PSAzureVMModule @params

                $install.Status | Should Be 'OK'
                $install.Message | Should Be 'Modules where installed without errors.'

                $params = $null
            }

            It "Should add arguments if a String is provided" {
                $params = @{
                    Name = "TestModule"
                    SubscriptionId = 'id'
                    ResourceGroupName = 'rg1'
                    VMName = 'vm1'
                    FileName = 'file1.ps1'
                    StorageAccountName = 'sto1'
                    Container = 'scripts'
                    Argument = '-User user1'
                }

                $install = Install-PSAzureVMModule @params

                $install.Status | Should Be 'OK'
                $install.Message | Should Be 'Modules where installed without errors.'
            }

            It "Should create a script and upload it to a storage account if it's specified" {

                Mock New-AzureStorageContext { }
                Mock Set-AzureStorageBlobContent { return @{Name='file1.ps1'}}
                Mock Remove-AzureStorageBlob { return $true }

                $newParams = @{
                    Name = "TestModule"
                    SubscriptionId = 'id'
                    ResourceGroupName = 'rg1'
                    VMName = 'vm1'
                    FileName = 'file1.ps1'
                    StorageAccountName = 'sto1'
                    Container = 'scripts'
                    UploadScript = $true
                    RepositoryName = 'TestRepo'
                    RepositoryPath = '\\path\to\repo'
                    Argument = '-User user1'
                }

                $install = Install-PSAzureVMModule @newParams
            }

            It "Should throw if not StorageAccount/Container or FileUri is specified" {
                $params = @{
                    Name = "TestModule"
                    SubscriptionId = 'id'
                    ResourceGroupName = 'rg1'
                    VMName = 'vm1'
                    FileName = 'file1.ps1'
                    StorageAccountName = $null
                    Container = $null
                }

                { Install-PSAzureVMModule @params } | Should throw 
            }

            It "Should throw if Storage Account key cannot be specified" {

                Mock Get-AzureRmStorageAccountKey { throw }

                $params = @{
                    Name = "TestModule"
                    SubscriptionId = 'id'
                    ResourceGroupName = 'rg1'
                    VMName = 'vm1'
                    FileName = 'file1.ps1'
                    StorageAccountName = 'sto1'
                    Container = 'scripts'
                }

                { Install-PSAzureVMModule @params } | Should throw
            }

            It "Should return the correct Status and Message if the script run fails" {

                Mock Set-AzureRmVMCustomScriptExtension { throw }

                Mock Get-AzureRmStorageAccountKey {
                    return @{ Value = @('longkey') }
                }

                $params = @{
                    Name = "TestModule"
                    SubscriptionId = 'id'
                    ResourceGroupName = 'rg1'
                    VMName = 'vm1'
                    FileName = 'file1.ps1'
                    StorageAccountName = 'sto1'
                    Container = 'scripts'
                }

                $install = Install-PSAzureVMModule @params

                $install.Status | Should Be 'Error'
                $install.Message | Should Be 'At least one Module failed installation. Please check logs on target server for more information.'

            }

            It "Should indicate in it's message if CustomScriptExtension could not be removed" {

                Mock Remove-AzureRmVMCustomScriptExtension { throw }

                $params = @{
                    Name = "TestModule"
                    SubscriptionId = 'id'
                    ResourceGroupName = 'rg1'
                    VMName = 'vm1'
                    FileName = 'file1.ps1'
                    StorageAccountName = 'sto1'
                    Container = 'scripts'
                }

                $install = Install-PSAzureVMModule @params

                $install.Status | Should Be 'Error'
                $install.Message | Should Be 'Modules where installed, but CustomScriptExtension could not be removed.'

            }

            It "Should throw if Azure Subscription cannot be selected" {

                Mock Select-AzureRmSubscription { throw }

                $params = @{
                    Name = "TestModule"
                    SubscriptionId = 'id'
                    ResourceGroupName = 'rg1'
                    VMName = 'vm1'
                    FileName = 'file1.ps1'
                    StorageAccountName = 'sto1'
                    Container = 'scripts'
                }

                { Install-PSAzureVMModule @params } | Should throw
            }
        }

        Context "No such VM" {

            Mock Get-AzureRmContext {
                return $true
            }

            Mock Login-AzureRmAccount {
                return $true
            }

            Mock Select-AzureRmSubscription { 
                return $true
            }

            Mock Get-AzureRmStorageAccountKey {
                return @{ Value = @('longkey') }
            }

            Mock Set-AzureRmVMCustomScriptExtension {
                return @{
                    'StatusCode' = 'OK'
                }
            }

            It "Should throw if VM could not be found" {

                function Get-AzureRmVM {
                    throw('No such VM')
                }

                $params = @{
                    Name = "TestModule"
                    SubscriptionId = 'id'
                    ResourceGroupName = 'rg1'
                    VMName = 'vm1'
                    FileName = 'file1.ps1'
                    StorageAccountName = 'sto1'
                    Container = 'scripts'
                }

                { Install-PSAzureVMModule @params } | Should throw
            }
        }
    }
}
