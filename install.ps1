param(
    [Parameter(Mandatory = $true)]
    [string]$TargetRoot,
    [string]$ProjectName = "",
    [string]$LastVerifiedDate = "",
    [string]$DefaultBranch = "",
    [switch]$Force
)

$ErrorActionPreference = "Stop"

$TemplateRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$TargetRoot = [System.IO.Path]::GetFullPath($TargetRoot)

$ManifestPath = Join-Path $TemplateRoot "KIT_MANIFEST.json"
if (-not (Test-Path -LiteralPath $ManifestPath)) {
    Write-Error "Missing KIT_MANIFEST.json beside install.ps1."
}

$manifest = Get-Content -Raw -LiteralPath $ManifestPath | ConvertFrom-Json
$files = @($manifest.installFiles)

if (-not (Test-Path -LiteralPath $TargetRoot)) {
    New-Item -ItemType Directory -Path $TargetRoot | Out-Null
}

$wouldOverwrite = @()
foreach ($file in $files) {
    $target = Join-Path $TargetRoot $file
    if ((Test-Path -LiteralPath $target) -and -not $Force) {
        $wouldOverwrite += $file
    }
}

if ($wouldOverwrite.Count -gt 0) {
    Write-Error ("Refusing to overwrite existing files without -Force:`n" + ($wouldOverwrite -join "`n"))
}

foreach ($file in $files) {
    $source = Join-Path $TemplateRoot $file
    $target = Join-Path $TargetRoot $file
    $targetDir = Split-Path -Parent $target
    if (-not (Test-Path -LiteralPath $targetDir)) {
        New-Item -ItemType Directory -Path $targetDir | Out-Null
    }

    $extension = [System.IO.Path]::GetExtension($source).ToLowerInvariant()
    $isText = @(".md", ".json", ".ps1", ".txt") -contains $extension
    $hasReplacement = (-not [string]::IsNullOrWhiteSpace($ProjectName)) -or
        (-not [string]::IsNullOrWhiteSpace($LastVerifiedDate)) -or
        (-not [string]::IsNullOrWhiteSpace($DefaultBranch))

    if ($isText -and $hasReplacement) {
        $content = Get-Content -Raw -LiteralPath $source
        if (-not [string]::IsNullOrWhiteSpace($ProjectName)) {
            $content = $content.Replace("[PROJECT_NAME]", $ProjectName)
        }
        if (-not [string]::IsNullOrWhiteSpace($LastVerifiedDate)) {
            $content = $content.Replace("[YYYY-MM-DD]", $LastVerifiedDate)
        }
        if (-not [string]::IsNullOrWhiteSpace($DefaultBranch)) {
            $content = $content.Replace("[DEFAULT_BRANCH]", $DefaultBranch)
        }
        [System.IO.File]::WriteAllText($target, $content, [System.Text.UTF8Encoding]::new($false))
    }
    else {
        Copy-Item -LiteralPath $source -Destination $target -Force:$Force
    }
}

Write-Output "Installed generic agent governance template to $TargetRoot"
