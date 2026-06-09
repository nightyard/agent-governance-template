param(
    [string]$TargetRoot = (Get-Location).Path,
    [switch]$Force
)

$ErrorActionPreference = "Stop"
$TargetRoot = [System.IO.Path]::GetFullPath($TargetRoot)
$TemplateRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$KitRoot = Split-Path -Parent $TemplateRoot
$BrokerTemplateDir = Join-Path $KitRoot ".agents/templates/brokers"

if (-not (Test-Path -LiteralPath $BrokerTemplateDir)) {
    Write-Error "Missing broker templates: $BrokerTemplateDir"
}

if (-not (Test-Path -LiteralPath $TargetRoot)) {
    Write-Error "TargetRoot does not exist: $TargetRoot"
}

$files = @(
    @{ Source = "multiagent-broker.mjs"; Target = "scripts/multiagent-broker.mjs" },
    @{ Source = "build-multiagent-evidence-packet.mjs"; Target = "scripts/build-multiagent-evidence-packet.mjs" },
    @{ Source = "cli-delegate-broker.mjs"; Target = "scripts/cli-delegate-broker.mjs" },
    @{ Source = "browser-agent-broker.mjs"; Target = "scripts/browser-agent-broker.mjs" },
    @{ Source = "dev-server-broker.mjs"; Target = "scripts/dev-server-broker.mjs" },
    @{ Source = "../BROKER_BUILD_SPEC.example.json"; Target = ".agents/runtime/MULTIAGENT_BROKER_BUILD.json" }
)

$wouldOverwrite = @()
foreach ($file in $files) {
    $target = Join-Path $TargetRoot $file.Target
    if ((Test-Path -LiteralPath $target) -and -not $Force) {
        $wouldOverwrite += $file.Target
    }
}

if ($wouldOverwrite.Count -gt 0) {
    Write-Error ("Refusing to overwrite existing broker files without -Force:`n" + ($wouldOverwrite -join "`n"))
}

$copied = New-Object System.Collections.Generic.List[string]
foreach ($file in $files) {
    $source = [System.IO.Path]::GetFullPath((Join-Path $BrokerTemplateDir $file.Source))
    $target = Join-Path $TargetRoot $file.Target
    $targetDir = Split-Path -Parent $target
    if (-not (Test-Path -LiteralPath $targetDir)) {
        New-Item -ItemType Directory -Path $targetDir | Out-Null
    }
    Copy-Item -LiteralPath $source -Destination $target -Force:$Force
    $copied.Add($file.Target) | Out-Null
}

Write-Output "Scaffolded generic multiagent broker files in $TargetRoot"
$copied | ForEach-Object { Write-Output "- $_" }
Write-Output "Next: customize .agents/runtime/MULTIAGENT_RUNTIME_SETTINGS.json and .agents/runtime/MULTIAGENT_BROKER_BUILD.json, then run scripts/check-agent-runtimes.ps1."
