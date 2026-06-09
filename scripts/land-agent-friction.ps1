param(
    [Parameter(Mandatory = $true)]
    [string]$EntryPath,
    [ValidateSet("landed", "declined")]
    [string]$Outcome = "landed",
    [string]$Reference = "",
    [string]$TargetRoot = (Get-Location).Path
)

$ErrorActionPreference = "Stop"
$TargetRoot = [System.IO.Path]::GetFullPath($TargetRoot)
$resolvedEntry = [System.IO.Path]::GetFullPath((Join-Path $TargetRoot $EntryPath))
$frictionRoot = [System.IO.Path]::GetFullPath((Join-Path $TargetRoot ".planning/friction"))

if (-not $resolvedEntry.StartsWith($frictionRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
    Write-Error "EntryPath must be inside .planning/friction."
}
if (-not (Test-Path -LiteralPath $resolvedEntry)) {
    Write-Error "Friction entry not found: $resolvedEntry"
}

$content = Get-Content -Raw -LiteralPath $resolvedEntry
$content = $content -replace 'Status:\s*\w+', "Status: $Outcome"
$content = $content -replace 'Outcome:\s*\[[^\]]+\]|Outcome:\s*\w+', "Outcome: $Outcome"
if (-not [string]::IsNullOrWhiteSpace($Reference)) {
    $content = $content -replace 'Reference:\s*.*', "Reference: $Reference"
}

[System.IO.File]::WriteAllText($resolvedEntry, $content, [System.Text.UTF8Encoding]::new($false))
Write-Output "updated $EntryPath to $Outcome"
