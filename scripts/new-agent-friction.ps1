param(
    [Parameter(Mandatory = $true)]
    [string]$Slug,
    [string]$Title = "",
    [string]$TargetRoot = (Get-Location).Path
)

$ErrorActionPreference = "Stop"
$TargetRoot = [System.IO.Path]::GetFullPath($TargetRoot)
$safeSlug = ($Slug.ToLowerInvariant() -replace '[^a-z0-9\-]+', '-' -replace '(^-+|-+$)', '')
if ([string]::IsNullOrWhiteSpace($safeSlug)) {
    Write-Error "Slug must contain at least one letter or number."
}

$template = Join-Path $TargetRoot ".agents/templates/FRICTION_ENTRY_TEMPLATE.md"
if (-not (Test-Path -LiteralPath $template)) {
    Write-Error "Missing friction template: $template"
}

$outDir = Join-Path $TargetRoot ".planning/friction"
if (-not (Test-Path -LiteralPath $outDir)) {
    New-Item -ItemType Directory -Path $outDir | Out-Null
}

$date = Get-Date -Format "yyyy-MM-dd"
$outPath = Join-Path $outDir "$date-$safeSlug.md"
if (Test-Path -LiteralPath $outPath) {
    Write-Error "Friction entry already exists: $outPath"
}

$content = Get-Content -Raw -LiteralPath $template
if (-not [string]::IsNullOrWhiteSpace($Title)) {
    $content = $content.Replace("[short title]", $Title)
}

[System.IO.File]::WriteAllText($outPath, $content, [System.Text.UTF8Encoding]::new($false))
Write-Output $outPath
