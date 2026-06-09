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

$template = Join-Path $TargetRoot ".agents/templates/SPEC_TEMPLATE.md"
if (-not (Test-Path -LiteralPath $template)) {
    Write-Error "Missing spec template: $template"
}

$outDir = Join-Path $TargetRoot ".planning"
if (-not (Test-Path -LiteralPath $outDir)) {
    New-Item -ItemType Directory -Path $outDir | Out-Null
}

$outPath = Join-Path $outDir "$safeSlug`_SPEC.md"
if (Test-Path -LiteralPath $outPath) {
    Write-Error "Spec already exists: $outPath"
}

$content = Get-Content -Raw -LiteralPath $template
if (-not [string]::IsNullOrWhiteSpace($Title)) {
    $content = $content.Replace("[Task Name]", $Title)
}

[System.IO.File]::WriteAllText($outPath, $content, [System.Text.UTF8Encoding]::new($false))
Write-Output $outPath
