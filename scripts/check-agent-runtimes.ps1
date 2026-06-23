param(
    [string]$TargetRoot = (Get-Location).Path,
    [string]$SettingsPath = "",
    [string[]]$CliAgents = @(),
    [string[]]$BrowserAgents = @(),
    [string]$OutputPath = "",
    [int]$TimeoutSeconds = 20
)

$ErrorActionPreference = "Stop"
$TargetRoot = [System.IO.Path]::GetFullPath($TargetRoot)

if ([string]::IsNullOrWhiteSpace($SettingsPath)) {
    $candidate = Join-Path $TargetRoot ".agents/runtime/MULTIAGENT_RUNTIME_SETTINGS.json"
    if (Test-Path -LiteralPath $candidate) {
        $SettingsPath = $candidate
    }
    else {
        $SettingsPath = Join-Path (Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)) ".agents/templates/MULTIAGENT_RUNTIME_SETTINGS.example.json"
    }
}

if ([string]::IsNullOrWhiteSpace($OutputPath)) {
    $OutputPath = Join-Path $TargetRoot ".planning/onboarding/agent-runtime-readiness.local.json"
}

$SettingsPath = [System.IO.Path]::GetFullPath($SettingsPath)
$OutputPath = [System.IO.Path]::GetFullPath($OutputPath)

function Test-CommandPresent([string]$Command) {
    if ([string]::IsNullOrWhiteSpace($Command) -or $Command -match '^\[') {
        return $false
    }
    return $null -ne (Get-Command $Command -ErrorAction SilentlyContinue)
}

function Invoke-CommandCheck([string]$Command, [object[]]$Arguments, [int]$Timeout) {
    $result = [ordered]@{
        attempted = $false
        timedOut = $false
        exitCode = $null
        outputPreview = ""
    }

    if (-not (Test-CommandPresent $Command)) {
        return $result
    }

    $argsList = @()
    if ($Arguments) {
        $argsList = @($Arguments | ForEach-Object { [string]$_ })
    }

    $job = Start-Job -ScriptBlock {
        param($cmd, $argList)
        $out = & $cmd @argList 2>&1 | Out-String
        [pscustomobject]@{
            ExitCode = $LASTEXITCODE
            Output = $out
        }
    } -ArgumentList $Command, $argsList

    $result.attempted = $true
    if (-not (Wait-Job -Job $job -Timeout $Timeout)) {
        Stop-Job -Job $job -ErrorAction SilentlyContinue
        Remove-Job -Job $job -Force -ErrorAction SilentlyContinue
        $result.timedOut = $true
        return $result
    }

    $jobResult = Receive-Job -Job $job
    Remove-Job -Job $job -Force -ErrorAction SilentlyContinue

    if ($jobResult) {
        $result.exitCode = $jobResult.ExitCode
        $output = [string]$jobResult.Output
        $output = $output -replace "(?im)\b(api[_-]?key|access[_-]?token|refresh[_-]?token|session[_-]?cookie|client[_-]?secret|password)\s*[:=]\s*['""]?[^'""\s]+['""]?", '$1=[REDACTED]'
        if ($output.Length -gt 500) {
            $output = $output.Substring(0, 500) + "`n...[truncated]"
        }
        $result.outputPreview = $output.Trim()
    }

    return $result
}

function Get-OsName {
    if ([System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform([System.Runtime.InteropServices.OSPlatform]::Windows)) {
        return "windows"
    }
    if ([System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform([System.Runtime.InteropServices.OSPlatform]::OSX)) {
        return "macos"
    }
    if ([System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform([System.Runtime.InteropServices.OSPlatform]::Linux)) {
        return "linux"
    }
    return "unknown"
}

function Select-Agents($ConfiguredAgents, [string[]]$SelectedIds) {
    $configured = @($ConfiguredAgents)
    if ($SelectedIds.Count -gt 0) {
        return @($configured | Where-Object { $SelectedIds -contains $_.id })
    }
    return @($configured | Where-Object { $_.enabled -eq $true })
}

if (-not (Test-Path -LiteralPath $SettingsPath)) {
    Write-Error "Missing multiagent runtime settings: $SettingsPath"
}

$settings = Get-Content -Raw -LiteralPath $SettingsPath | ConvertFrom-Json
$osName = Get-OsName
$selectedCliAgents = Select-Agents $settings.cliAgents $CliAgents
$selectedBrowserAgents = Select-Agents $settings.browserAgents $BrowserAgents

$cliResults = New-Object System.Collections.Generic.List[object]
foreach ($agent in $selectedCliAgents) {
    $command = [string]$agent.command
    $present = Test-CommandPresent $command
    $versionCheck = Invoke-CommandCheck $command @($agent.versionArgs) $TimeoutSeconds
    $statusArgs = @($agent.statusArgs)
    $statusCheck = $null
    $authStatus = "unknown_no_status_command_configured"
    if ($statusArgs.Count -gt 0) {
        $statusCheck = Invoke-CommandCheck $command $statusArgs $TimeoutSeconds
        if ($statusCheck.attempted -and -not $statusCheck.timedOut -and $statusCheck.exitCode -eq 0) {
            $authStatus = "status_command_passed"
        }
        elseif ($statusCheck.attempted) {
            $authStatus = "status_command_failed_or_not_signed_in"
        }
    }

    $cliResults.Add([ordered]@{
        id = $agent.id
        command = $command
        commandPresent = $present
        versionCheck = $versionCheck
        authStatus = $authStatus
        statusCheck = $statusCheck
        userAction = if (-not $present) {
            "Install this CLI or deselect it."
        }
        elseif ($authStatus -eq "status_command_failed_or_not_signed_in") {
            $agent.loginInstructions
        }
        elseif ($authStatus -eq "unknown_no_status_command_configured") {
            "No non-secret status command is configured. If delegation fails, run the provider's interactive login/status flow, then rerun this script."
        }
        else {
            "No user action required."
        }
    }) | Out-Null
}

$browserResults = New-Object System.Collections.Generic.List[object]
foreach ($agent in $selectedBrowserAgents) {
    $browserResults.Add([ordered]@{
        id = $agent.id
        url = $agent.url
        authStatus = "requires_visible_browser_check"
        readinessCheck = $agent.readinessCheck
        userAction = "Use the configured browser automation tool to open the URL. If a login screen is visible, ask the user to sign in interactively, then re-check the visible app state. Do not inspect browser profiles, cookies, local storage, or auth caches."
    }) | Out-Null
}

$questions = New-Object System.Collections.Generic.List[object]
if ($selectedCliAgents.Count -eq 0 -and $selectedBrowserAgents.Count -eq 0) {
    $questions.Add([ordered]@{
        id = "select_multiagent_runtimes"
        question = "Which CLI agents and browser agents should this workspace support?"
        reason = "No enabled agents were found in the runtime settings and none were passed on the command line."
    }) | Out-Null
}

if ($osName -ne "windows") {
    $questions.Add([ordered]@{
        id = "port_multiagent_runtime"
        question = "Should the agent port the Windows-first broker/CLI/browser runtime scripts for $osName before enabling multiagent delegation?"
        reason = "The kit governance is portable, but broker/process/browser helper scripts are Windows-first until project-owned ports are implemented and tested."
    }) | Out-Null
}

$report = [ordered]@{
    schema_version = 1
    generatedAtUtc = (Get-Date).ToUniversalTime().ToString("o")
    targetRoot = $TargetRoot
    settingsPath = $SettingsPath
    os = [ordered]@{
        detected = $osName
        windowsFirstRuntime = $true
        macosOrLinuxPortRequiredBeforeBrokerUse = ($osName -ne "windows")
    }
    runtimeStatus = [ordered]@{
        coordinationSkill = "installed_when_.agents/skills/clearroute-multiagent_exists"
        brokerScriptsBundled = $false
        cliBrowserDelegationUsable = if ($osName -eq "windows") { "only_after_selected_agents_and_project_brokers_are_configured" } else { "no_port_runtime_first" }
    }
    cliAgents = $cliResults
    browserAgents = $browserResults
    questions = $questions
    nextSteps = @(
        "Ask the user which CLI and browser agents to enable if none are selected.",
        "Run this script before asking the user to sign in.",
        "For CLI agents with failed status checks, ask the user to run the provider's interactive login flow, then rerun this script.",
        "For browser agents, open the provider URL with browser automation and inspect only visible login/app state.",
        "Do not inspect or export cookies, browser profiles, local storage, keychains, token files, or CLI auth caches.",
        "Do not mark the multiagent runtime usable until broker scripts/adapters are configured and verified locally."
    )
}

$outputDir = Split-Path -Parent $OutputPath
if (-not (Test-Path -LiteralPath $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir | Out-Null
}

$json = $report | ConvertTo-Json -Depth 12
[System.IO.File]::WriteAllText($OutputPath, $json, [System.Text.UTF8Encoding]::new($false))

Write-Output "Wrote agent runtime readiness report to $OutputPath"
Write-Output "Detected OS: $osName"
Write-Output "CLI agents checked: $($cliResults.Count)"
Write-Output "Browser agents requiring visible checks: $($browserResults.Count)"
if ($osName -ne "windows") {
    Write-Output "PORT_REQUIRED: broker, CLI, browser, and dev-server helper runtime scripts must be ported before use."
}
