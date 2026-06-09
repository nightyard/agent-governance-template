param(
    [Parameter(Mandatory = $true)]
    [string]$TaskId,
    [Parameter(Mandatory = $true)]
    [string]$Status,
    [string]$Summary = "",
    [string]$TargetRoot = (Get-Location).Path
)

$ErrorActionPreference = "Stop"
$TargetRoot = [System.IO.Path]::GetFullPath($TargetRoot)
$planningDir = Join-Path $TargetRoot ".planning"
if (-not (Test-Path -LiteralPath $planningDir)) {
    New-Item -ItemType Directory -Path $planningDir | Out-Null
}

$checkpointPath = Join-Path $planningDir "agent-checkpoints.md"
if (-not (Test-Path -LiteralPath $checkpointPath)) {
    [System.IO.File]::WriteAllText($checkpointPath, "# Agent Checkpoints`n`n", [System.Text.UTF8Encoding]::new($false))
}

$line = "- " + (Get-Date).ToUniversalTime().ToString("o") + " | " + $TaskId + " | " + $Status + " | " + $Summary
[System.IO.File]::AppendAllText($checkpointPath, $line + [Environment]::NewLine, [System.Text.UTF8Encoding]::new($false))
Write-Output $checkpointPath
