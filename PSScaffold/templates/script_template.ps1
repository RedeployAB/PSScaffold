$scriptTemplate = @"
`$repoName = '$RepositoryName'
`$repoPath = '$RepositoryPath'


"@
# Adding drive.
if (!([string]::IsNullOrEmpty($StorageAccountName)) -and !([string]::IsNullOrEmpty($StorageAccountKey))) {
    $mapURI = Split-Path $RepositoryPath -Parent
    $scriptTemplate += "net use Z: $mapURI /u:AZURE\$StorageAccountName $StorageAccountKey"
}

# Check if repository exists and is mapped.
$scriptTemplate += @"


Write-Output("Checking if Repsitory: {0} is registered." -f `$repoName)
if (-not (Get-PSRepository -Name `$repoName)) {
    Write-Output("Repository: {0} is not registered. Registering." -f `$repoName)
    if (!(Test-Path `$repoPath)) { 
        throw "Could not reach `$repoPath. Ensure that the path has been mapped as a local Network Drive."
    } else {
        Register-PSRepository -Name `$repoName -SourceLocation `$repoPath -PublishLocation `$repoPath -InstallationPolicy Trusted
    }
}

Write-Output("Checking if path to Repository: {0} is reachable." -f `$repoPath)
if (!(Test-Path `$repoPath)) {
    throw "Could not reach `$repoPath. Ensure that the path has been mapped as a local Network Drive."
}

`$moduleInstalledOrUpdated = `$false
Write-Output("Checking if Module: $Module is installed.")
`$psModule = Get-Module -Name $Module -ListAvailable 
if (`$psModule) {
    # If the module is newer on the repository. Update it.
    Write-Output("Module: $Module is installed.")
    Write-Output("Comparing version of installed module and module in Repository: {0}" -f `$repoName)
    `$localVersion = `$psModule.Version
    `$repoVersion = (Find-Module -Name $Module -Repository `$repoName).Version

    if (`$localVersion -lt `$repoVersion) {
        Write-Output("A newer version is available. Updating module.")
        Update-Module -Name $Module
        `$moduleInstalledOrUpdated = `$true
        `$message = "Module: $Module was successfully updated."
    }

} else {
    Write-Output("Could not find Module: $Module. Installing.")
    Install-Module -Name $Module -Repository `$repoName
    `$moduleInstalledOrUpdated = `$true
    `$message = "Module: $Module was successfully installed."
}

if (`$moduleInstalledOrUpdated) {
    `$status = 'OK'
} else {
    `$status = 'NotInstalledOrUpdated'
}


"@

if (!([string]::IsNullOrEmpty($StorageAccountName)) -and !([string]::IsNullOrEmpty($StorageAccountKey))) {
    
    $scriptTemplate += "net use Z: /delete"
}

$scriptTemplate += @"


`$result = [PSCustomObject]@{
    'Status' = `$status
    'Message' = `$message
}
"@