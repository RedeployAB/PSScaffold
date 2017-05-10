$BuildFileContent = @"
# Include: Settings.
. './<module>.settings.ps1'

# Include: build_utils.
. './build_utils.ps1'

#Synopsis: Run/Publish Tests and Fail Build on Error.
task Test BeforeTest, RunTests, ConfirmTestsPassed, AfterTest

#Synopsis: Run full Pipeline.
task . Clean, Analyze, Test, Publish

#Synopsis: Install dependencies.
task InstallDependencies {}

#Synopsis: Clean Artifact directory.
task Clean BeforeClean, {
    
    if (Test-Path -Path `$Artifacts) {
        Remove-Item "`$Artifacts/*" -Recurse -Force
    }

    New-Item -ItemType Directory -Path `$Artifacts -Force

    & git clone https://github.com/Xainey/PSTestReport.git

}, AfterClean

#Synopsis: Analyze code.
task Analyze BeforeAnalyze, {
    `$scriptAnalyzerParams = @{
        Path = `$ModulePath
        ExcludeRule = @('PSPossibleIncorrectComparisonWithNull', 'PSUseToExportFieldsInManifest')
        Severity = @('Error', 'Warning')
        Recurse = `$true
        Verbose = `$false
    }

    `$saResults = Invoke-ScriptAnalyzer @scriptAnalyzerParams
    # Save the results.
    `$saResults | ConvertTo-Json | Set-Content (Join-Path `$Artifacts "ScriptAnalysisResults.json")
}, AfterAnalyze

#Synopsis: Run tests.
task RunTests {
    `$invokePesterParams = @{
        OutputFile = (Join-Path `$Artifacts "TestResults.xml")
        OutputFormat = "NUnitXml"
        Strict = `$true
        PassThru = `$true
        Verbose = `$false
        EnableExit = `$false
        CodeCoverage = (Get-ChildItem -Path "`$ModulePath\*.ps1" -Exclude "*.Tests.*" -Recurse).FullName
    }

    `$testResults = Invoke-Pester @invokePesterParams

    `$testResults | ConvertTo-Json -Depth 5 | Set-Content (Join-Path `$Artifacts "PesterResults.json")

    `$options = @{
        BuildNumber = `$BuildNumber
        GitRepo = `$Settings.GitRepo
        GetRepoUrl = `$Settings.ProjectUrl
        CiURL = `$Settings.CiURL
        ShowHitCommands = `$true
        Compliance = (`$PercentCompliance / 100)
        ScriptAnalyzerFile = (Join-Path `$Artifacts "ScriptAnalysisResults.json")
        PesterFile = (Join-Path `$Artifacts "PesterResults.json")
        OutputDir = "`$Artifacts"
    }

    . ".\PSTestReport\Invoke-PSTestReport.ps1" @options
}

#Synopsis: Confirm that tests passed.
task ConfirmTestsPassed {
    # Fail Build after reports are created, this allows CI to publish test results before failing
    [xml]`$xml = Get-Content (Join-Path `$Artifacts "TestResults.xml")
    `$numberFails = `$xml."test-results".failures
    assert(`$numberFails -eq 0) ('Failed "{0}" unit tests.' -f `$numberFails)

    # Fail Build if Coverage is under requirement
    `$json = Get-Content (Join-Path `$Artifacts "PesterResults.json") | ConvertFrom-Json
    `$overallCoverage = [Math]::Floor((`$json.CodeCoverage.NumberOfCommandsExecuted / `$json.CodeCoverage.NumberOfCommandsAnalyzed) * 100)
    assert(`$OverallCoverage -gt `$PercentCompliance) ('A Code Coverage of "{0}" does not meet the build requirement of "{1}"' -f `$overallCoverage, `$PercentCompliance)
}

#Synopsis: Publish to SMB File Share.
task Publish BeforePublish, {
    
    `$moduleInfo = @{
        RepositoryName = `$Settings.SMBRepositoryName
        RepositoryPath = `$Settings.SMBRepositoryPath
        ModuleName = `$ModuleName
        ModulePath = "`$ModulePath\`$ModuleName.psd1"
        BuildNumber = `$BuildNumber
    }

    Publish-SMBModule @moduleInfo -Verbose

}, AfterPublish
"@