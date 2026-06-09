param(
    [Parameter(Mandatory = $true)]
    [string]$AgentId,
    [Parameter(Mandatory = $true)]
    [string]$TaskId,
    [Parameter(Mandatory = $true)]
    [string[]]$WriteScope,
    [string]$Notes = "",
    [string]$TargetRoot = (Get-Location).Path
)

$ErrorActionPreference = "Stop"
$TargetRoot = [System.IO.Path]::GetFullPath($TargetRoot)
$planningDir = Join-Path $TargetRoot ".planning"
if (-not (Test-Path -LiteralPath $planningDir)) {
    New-Item -ItemType Directory -Path $planningDir | Out-Null
}

$lockPath = Join-Path $planningDir "write-locks.json"
$claims = @()
if (Test-Path -LiteralPath $lockPath) {
    $state = Get-Content -Raw -LiteralPath $lockPath | ConvertFrom-Json
    if ($state.claims) {
        $claims = @($state.claims)
    }
}

$claimId = "claim-" + ([System.Guid]::NewGuid().ToString("N"))
$claim = [ordered]@{
    claim_id = $claimId
    agent_id = $AgentId
    task_id = $TaskId
    write_scope = @($WriteScope)
    notes = $Notes
    status = "active"
    claimed_at_utc = (Get-Date).ToUniversalTime().ToString("o")
}

$state = [ordered]@{ claims = @($claims) + @($claim) }
$json = $state | ConvertTo-Json -Depth 8
[System.IO.File]::WriteAllText($lockPath, $json + [Environment]::NewLine, [System.Text.UTF8Encoding]::new($false))
Write-Output $claimId
