param(
    [Parameter(Mandatory = $true)]
    [string]$ClaimId,
    [string]$TargetRoot = (Get-Location).Path
)

$ErrorActionPreference = "Stop"
$TargetRoot = [System.IO.Path]::GetFullPath($TargetRoot)
$lockPath = Join-Path (Join-Path $TargetRoot ".planning") "write-locks.json"
if (-not (Test-Path -LiteralPath $lockPath)) {
    Write-Error "No write-locks.json found."
}

$state = Get-Content -Raw -LiteralPath $lockPath | ConvertFrom-Json
$found = $false
$claims = @()
foreach ($claim in @($state.claims)) {
    if ([string]$claim.claim_id -eq $ClaimId) {
        $claim.status = "released"
        $claim | Add-Member -NotePropertyName "released_at_utc" -NotePropertyValue (Get-Date).ToUniversalTime().ToString("o") -Force
        $found = $true
    }
    $claims += $claim
}

if (-not $found) {
    Write-Error "Claim not found: $ClaimId"
}

$outState = [ordered]@{ claims = $claims }
$json = $outState | ConvertTo-Json -Depth 8
[System.IO.File]::WriteAllText($lockPath, $json + [Environment]::NewLine, [System.Text.UTF8Encoding]::new($false))
Write-Output "released $ClaimId"
