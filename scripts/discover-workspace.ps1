param(
    [string]$TargetRoot = (Get-Location).Path,
    [string]$OutputPath = "",
    [int]$MaxExcerptChars = 1200,
    [switch]$NoExcerpts
)

$ErrorActionPreference = "Stop"
$TargetRoot = [System.IO.Path]::GetFullPath($TargetRoot)

if (-not (Test-Path -LiteralPath $TargetRoot)) {
    Write-Error "TargetRoot does not exist: $TargetRoot"
}

$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$TemplateRoot = Split-Path -Parent $ScriptRoot

if ([string]::IsNullOrWhiteSpace($OutputPath)) {
    $OutputPath = Join-Path $TargetRoot ".planning/onboarding/workspace-discovery.local.json"
}
elseif (-not [System.IO.Path]::IsPathRooted($OutputPath)) {
    $OutputPath = [System.IO.Path]::GetFullPath((Join-Path (Get-Location).Path $OutputPath))
}
else {
    $OutputPath = [System.IO.Path]::GetFullPath($OutputPath)
}

function Join-Target([string]$RelativePath) {
    return (Join-Path $TargetRoot $RelativePath)
}

function ConvertTo-RepoPath([string]$Path) {
    $full = [System.IO.Path]::GetFullPath($Path)
    if ($full.StartsWith($TargetRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        $relative = $full.Substring($TargetRoot.Length).TrimStart([char[]]@('\', '/'))
        return ($relative -replace '\\', '/')
    }
    return ($Path -replace '\\', '/')
}

function Redact-Text([string]$Text) {
    if ($null -eq $Text) {
        return ""
    }

    $redacted = $Text
    $redacted = $redacted -replace "-----BEGIN[\s\S]+?-----END [^-]+KEY-----", "[REDACTED_PRIVATE_KEY]"
    $redacted = $redacted -replace "(?im)\b(api[_-]?key|access[_-]?token|refresh[_-]?token|session[_-]?cookie|client[_-]?secret|password)\s*[:=]\s*['""]?[^'""\s]+['""]?", '$1=[REDACTED]'
    $redacted = $redacted -replace "(?i)(https?://)([^/\s:@]+):([^/\s@]+)@", '$1[REDACTED]@'
    return $redacted
}

function Get-SafeExcerpt([string]$Path) {
    if ($NoExcerpts) {
        return $null
    }

    $fileName = [System.IO.Path]::GetFileName($Path)
    if ($fileName -match '^(?:\.env|id_rsa|id_dsa|id_ecdsa|id_ed25519)$') {
        return $null
    }

    try {
        $item = Get-Item -LiteralPath $Path
        if ($item.Length -gt 262144) {
            return "[omitted: file larger than 256 KiB]"
        }

        $text = Get-Content -Raw -LiteralPath $Path
        $text = Redact-Text $text
        if ($text.Length -gt $MaxExcerptChars) {
            return ($text.Substring(0, $MaxExcerptChars) + "`n...[truncated]")
        }
        return $text
    }
    catch {
        return "[omitted: could not read text safely]"
    }
}

function New-FileRecord([string]$RelativePath, [string]$Kind, [bool]$IncludeExcerpt) {
    $path = Join-Target $RelativePath
    if (-not (Test-Path -LiteralPath $path)) {
        return $null
    }

    $item = Get-Item -LiteralPath $path
    if ($item.PSIsContainer) {
        return $null
    }

    $record = [ordered]@{
        path = (ConvertTo-RepoPath $path)
        kind = $Kind
        bytes = $item.Length
        lastWriteUtc = $item.LastWriteTimeUtc.ToString("o")
    }

    if ($IncludeExcerpt) {
        $record.excerpt = Get-SafeExcerpt $path
    }

    return $record
}

function Add-ExistingFile($List, [string]$RelativePath, [string]$Kind, [bool]$IncludeExcerpt) {
    $record = New-FileRecord $RelativePath $Kind $IncludeExcerpt
    if ($null -ne $record) {
        $List.Add($record) | Out-Null
    }
}

function Add-FilesFromFolder($List, [string]$RelativeFolder, [string[]]$Patterns, [string]$Kind, [int]$Limit, [bool]$IncludeExcerpt) {
    $folder = Join-Target $RelativeFolder
    if (-not (Test-Path -LiteralPath $folder)) {
        return
    }

    $count = 0
    foreach ($pattern in $Patterns) {
        $files = Get-ChildItem -LiteralPath $folder -Recurse -File -Filter $pattern -ErrorAction SilentlyContinue | Select-Object -First ($Limit - $count)
        foreach ($file in $files) {
            $record = New-FileRecord (ConvertTo-RepoPath $file.FullName) $Kind $IncludeExcerpt
            if ($null -ne $record) {
                $List.Add($record) | Out-Null
                $count++
            }
            if ($count -ge $Limit) {
                return
            }
        }
    }
}

function Invoke-Git([string[]]$GitArgs) {
    try {
        $output = & git -C $TargetRoot @GitArgs 2>$null
        if ($LASTEXITCODE -eq 0) {
            return (($output | Out-String).Trim())
        }
    }
    catch {
        return ""
    }
    return ""
}

function New-Inference($Value, [string]$Source, [string]$Confidence) {
    return [ordered]@{
        value = $Value
        source = $Source
        confidence = $Confidence
    }
}

function Add-Question($List, [string]$Id, [string]$Question, [string]$Reason, [bool]$Required) {
    $List.Add([ordered]@{
        id = $Id
        question = $Question
        reason = $Reason
        required = $Required
    }) | Out-Null
}

$governanceFiles = New-Object System.Collections.Generic.List[object]
$primaryDocs = New-Object System.Collections.Generic.List[object]
$packageFiles = New-Object System.Collections.Generic.List[object]
$ciFiles = New-Object System.Collections.Generic.List[object]
$riskHintFiles = New-Object System.Collections.Generic.List[object]
$installConflicts = New-Object System.Collections.Generic.List[object]
$verificationCommands = New-Object System.Collections.Generic.List[object]
$questions = New-Object System.Collections.Generic.List[object]

@(
    "AGENTS.md",
    "CLAUDE.md",
    "GEMINI.md",
    ".agents/rules/rules.md",
    ".agents/AGENT_SURFACES.md",
    ".agents/startup-profiles.json",
    ".cursorrules",
    ".windsurfrules",
    "rules.md",
    "WARP.md",
    ".github/copilot-instructions.md"
) | ForEach-Object { Add-ExistingFile $governanceFiles $_ "governance" $true }

Add-FilesFromFolder $governanceFiles ".cursor/rules" @("*.mdc", "*.md") "governance" 20 $true
Add-FilesFromFolder $governanceFiles ".github/instructions" @("*.md", "*.instructions.md") "governance" 20 $true

@(
    "README.md",
    "README.MD",
    "CONTRIBUTING.md",
    "SECURITY.md",
    "docs/INDEX.md",
    "docs/README.md",
    "docs/ARCHITECTURE.md",
    "docs/PROJECT_CONTEXT.md",
    "docs/WORKFLOW_PROTOCOL.md",
    "docs/SECURITY.md"
) | ForEach-Object { Add-ExistingFile $primaryDocs $_ "primary_doc" $true }

@(
    "package.json",
    "package-lock.json",
    "pnpm-lock.yaml",
    "yarn.lock",
    "bun.lockb",
    "pyproject.toml",
    "requirements.txt",
    "poetry.lock",
    "Cargo.toml",
    "Cargo.lock",
    "go.mod",
    "go.sum"
) | ForEach-Object { Add-ExistingFile $packageFiles $_ "package_or_runtime" $false }

Add-FilesFromFolder $ciFiles ".github/workflows" @("*.yml", "*.yaml") "ci_workflow" 50 $false
@(
    "azure-pipelines.yml",
    "azure-pipelines.yaml",
    ".gitlab-ci.yml",
    "Jenkinsfile",
    "Makefile"
) | ForEach-Object { Add-ExistingFile $ciFiles $_ "ci_or_task_runner" $false }

@(
    ".env",
    ".env.local",
    ".env.production",
    "Dockerfile",
    "docker-compose.yml",
    "docker-compose.yaml",
    "prisma/schema.prisma",
    "migrations",
    "db/migrations",
    "terraform"
) | ForEach-Object {
    $path = Join-Target $_
    if (Test-Path -LiteralPath $path) {
        $item = Get-Item -LiteralPath $path
        $riskHintFiles.Add([ordered]@{
            path = ($_ -replace '\\', '/')
            kind = if ($item.PSIsContainer) { "risk_hint_directory" } else { "risk_hint_file" }
            note = "Presence only; do not read secrets or apply production/data changes without user approval."
        }) | Out-Null
    }
}

$gitCurrentBranch = Invoke-Git @("branch", "--show-current")
$gitOriginUrl = Redact-Text (Invoke-Git @("config", "--get", "remote.origin.url"))
$gitDefaultBranchRaw = Invoke-Git @("symbolic-ref", "--quiet", "--short", "refs/remotes/origin/HEAD")
$gitDefaultBranch = ""
if (-not [string]::IsNullOrWhiteSpace($gitDefaultBranchRaw)) {
    $gitDefaultBranch = $gitDefaultBranchRaw -replace '^origin/', ''
}
elseif (Test-Path -LiteralPath (Join-Target ".git")) {
    if (Invoke-Git @("rev-parse", "--verify", "main") ) {
        $gitDefaultBranch = "main"
    }
    elseif (Invoke-Git @("rev-parse", "--verify", "master") ) {
        $gitDefaultBranch = "master"
    }
}

$projectName = $null
$projectNameSource = ""
$packageManager = $null
$packageManagerSource = ""
$runtime = New-Object System.Collections.Generic.List[string]

$packageJsonPath = Join-Target "package.json"
if (Test-Path -LiteralPath $packageJsonPath) {
    try {
        $packageJson = Get-Content -Raw -LiteralPath $packageJsonPath | ConvertFrom-Json
        if ($packageJson.name) {
            $projectName = [string]$packageJson.name
            $projectNameSource = "package.json:name"
        }
        if ($packageJson.packageManager) {
            $packageManager = ([string]$packageJson.packageManager).Split("@")[0]
            $packageManagerSource = "package.json:packageManager"
        }
        $runtime.Add("node") | Out-Null

        if ($packageJson.scripts) {
            $scriptNames = @("test", "lint", "build", "typecheck", "check", "verify")
            foreach ($scriptName in $scriptNames) {
                if ($packageJson.scripts.PSObject.Properties.Name -contains $scriptName) {
                    $runner = if ($packageManager) { $packageManager } else { "npm" }
                    $command = if ($runner -eq "npm" -and $scriptName -ne "test") { "npm run $scriptName" } elseif ($runner -eq "npm") { "npm test" } else { "$runner $scriptName" }
                    $verificationCommands.Add([ordered]@{
                        command = $command
                        source = "package.json:scripts.$scriptName"
                    }) | Out-Null
                }
            }
        }
    }
    catch {}
}

if (-not $packageManager) {
    if (Test-Path -LiteralPath (Join-Target "pnpm-lock.yaml")) {
        $packageManager = "pnpm"
        $packageManagerSource = "pnpm-lock.yaml"
    }
    elseif (Test-Path -LiteralPath (Join-Target "yarn.lock")) {
        $packageManager = "yarn"
        $packageManagerSource = "yarn.lock"
    }
    elseif (Test-Path -LiteralPath (Join-Target "bun.lockb")) {
        $packageManager = "bun"
        $packageManagerSource = "bun.lockb"
    }
    elseif (Test-Path -LiteralPath (Join-Target "package-lock.json")) {
        $packageManager = "npm"
        $packageManagerSource = "package-lock.json"
    }
}

$pyprojectPath = Join-Target "pyproject.toml"
if (Test-Path -LiteralPath $pyprojectPath) {
    $runtime.Add("python") | Out-Null
    if (-not $projectName) {
        $pyproject = Get-Content -Raw -LiteralPath $pyprojectPath
        if ($pyproject -match '(?m)^\s*name\s*=\s*["'']([^"'']+)["'']') {
            $projectName = $matches[1]
            $projectNameSource = "pyproject.toml:name"
        }
    }
    $verificationCommands.Add([ordered]@{
        command = "python -m pytest"
        source = "pyproject.toml present"
    }) | Out-Null
}
elseif (Test-Path -LiteralPath (Join-Target "requirements.txt")) {
    $runtime.Add("python") | Out-Null
    $verificationCommands.Add([ordered]@{
        command = "python -m pytest"
        source = "requirements.txt present; verify pytest is configured"
    }) | Out-Null
}

$cargoPath = Join-Target "Cargo.toml"
if (Test-Path -LiteralPath $cargoPath) {
    $runtime.Add("rust") | Out-Null
    if (-not $projectName) {
        $cargoToml = Get-Content -Raw -LiteralPath $cargoPath
        if ($cargoToml -match '(?m)^\s*name\s*=\s*["'']([^"'']+)["'']') {
            $projectName = $matches[1]
            $projectNameSource = "Cargo.toml:name"
        }
    }
    $verificationCommands.Add([ordered]@{
        command = "cargo test"
        source = "Cargo.toml present"
    }) | Out-Null
}

$goModPath = Join-Target "go.mod"
if (Test-Path -LiteralPath $goModPath) {
    $runtime.Add("go") | Out-Null
    if (-not $projectName) {
        $goMod = Get-Content -Raw -LiteralPath $goModPath
        if ($goMod -match '(?m)^\s*module\s+(.+)$') {
            $moduleName = $matches[1].Trim()
            $projectName = [System.IO.Path]::GetFileName($moduleName)
            $projectNameSource = "go.mod:module"
        }
    }
    $verificationCommands.Add([ordered]@{
        command = "go test ./..."
        source = "go.mod present"
    }) | Out-Null
}

if (-not $projectName -and -not [string]::IsNullOrWhiteSpace($gitOriginUrl)) {
    $remoteName = [System.IO.Path]::GetFileNameWithoutExtension(($gitOriginUrl -split '/|:')[-1])
    if (-not [string]::IsNullOrWhiteSpace($remoteName)) {
        $projectName = $remoteName
        $projectNameSource = "git remote origin"
    }
}

if (-not $projectName) {
    $projectName = Split-Path -Leaf $TargetRoot
    $projectNameSource = "directory name"
}

$manifestPath = Join-Path $TemplateRoot "KIT_MANIFEST.json"
if (Test-Path -LiteralPath $manifestPath) {
    try {
        $manifest = Get-Content -Raw -LiteralPath $manifestPath | ConvertFrom-Json
        foreach ($file in @($manifest.installFiles)) {
            $targetFile = Join-Target $file
            if (Test-Path -LiteralPath $targetFile) {
                $installConflicts.Add([ordered]@{
                    path = $file
                    recommendation = "stage-and-merge; do not overwrite without user approval"
                }) | Out-Null
            }
        }
    }
    catch {}
}

if ($projectNameSource -eq "directory name") {
    Add-Question $questions "project_name" "What display name should agents use for this project?" "Only a low-confidence directory-name inference was available." $true
}

if ([string]::IsNullOrWhiteSpace($gitDefaultBranch)) {
    Add-Question $questions "default_branch" "What is the shared/default branch for normal work?" "Git origin default branch could not be inferred." $true
}

if ($verificationCommands.Count -eq 0) {
    Add-Question $questions "verification_commands" "What commands should agents run for narrow checks, full tests, linting, type checks, and builds?" "No standard verification commands were inferred from package/runtime files." $true
}

Add-Question $questions "domain_gates" "What must agents never do without explicit approval in this repo?" "Needed to fill docs/DOMAIN_GATES.md; include production, data writes, billing, migrations, external notifications, dependencies, and destructive actions." $true
Add-Question $questions "private_data_policy" "What private data, customer data, credential, and external-tool sharing rules should agents follow?" "Needed before browser agents, web delegates, MCP tools, screenshots, or logs are used." $true
Add-Question $questions "owners" "Who owns product, engineering, security/data, release, and architecture decisions?" "Needed to fill owner/source fields and escalation paths." $true
Add-Question $questions "current_posture" "What is the current project phase, production status, active objective, and major blockers?" "Needed to fill docs/PROJECT_CONTEXT.md and .planning/ACTIVE_CONTEXT_STATE.json." $true

if ($governanceFiles.Count -gt 0) {
    Add-Question $questions "existing_rules_merge" "Which existing agent rules must be preserved verbatim, and which can be replaced by the new canonical AGENTS.md structure?" "Existing governance/rule files were discovered." $true
}

if ($installConflicts.Count -gt 0) {
    Add-Question $questions "install_conflicts" "The kit overlaps existing files. Should the agent install to a temporary staging folder and merge, or are any exact overwrites approved?" "The installer refuses overwrites unless -Force is supplied; use -Force only after explicit path-level approval." $true
}

$installMode = if ($installConflicts.Count -gt 0) { "stage-and-merge" } else { "direct-install" }
$defaultBranchValue = if ([string]::IsNullOrWhiteSpace($gitDefaultBranch)) { $gitCurrentBranch } else { $gitDefaultBranch }

$report = [ordered]@{
    schema_version = 1
    generatedAtUtc = (Get-Date).ToUniversalTime().ToString("o")
    target = [ordered]@{
        root = $TargetRoot
        directoryName = (Split-Path -Leaf $TargetRoot)
        git = [ordered]@{
            currentBranch = $gitCurrentBranch
            defaultBranch = $gitDefaultBranch
            originUrl = $gitOriginUrl
        }
    }
    inferred = [ordered]@{
        projectName = (New-Inference $projectName $projectNameSource ($(if ($projectNameSource -eq "directory name") { "low" } else { "medium" })))
        defaultBranch = (New-Inference $defaultBranchValue ($(if ($gitDefaultBranch) { "origin HEAD" } elseif ($gitCurrentBranch) { "current branch" } else { "not inferred" })) ($(if ($gitDefaultBranch) { "high" } elseif ($gitCurrentBranch) { "low" } else { "none" })))
        packageManager = (New-Inference $packageManager $packageManagerSource ($(if ($packageManager) { "high" } else { "none" })))
        runtime = ($runtime | Select-Object -Unique)
        verificationCommands = $verificationCommands
    }
    discovered = [ordered]@{
        governanceFiles = $governanceFiles
        primaryDocs = $primaryDocs
        packageFiles = $packageFiles
        ciFiles = $ciFiles
        riskHintFiles = $riskHintFiles
        installConflicts = $installConflicts
    }
    installRecommendation = [ordered]@{
        mode = $installMode
        reason = if ($installConflicts.Count -gt 0) { "Existing target files overlap the kit; preserve and merge current rules." } else { "No kit file conflicts were found." }
        directInstallCommand = "powershell -NoProfile -ExecutionPolicy Bypass -File .\install.ps1 -TargetRoot `"$TargetRoot`" -ProjectName `"$projectName`" -LastVerifiedDate `"$(Get-Date -Format yyyy-MM-dd)`" -DefaultBranch `"$defaultBranchValue`""
        conflictCount = $installConflicts.Count
    }
    questions = $questions
    nextSteps = @(
        "Read discovered.governanceFiles and discovered.primaryDocs before asking the user anything.",
        "Use inferred values when confidence is medium or high; ask the user only for missing decisions and low-confidence facts.",
        "Never ask the user for secrets, tokens, cookies, private keys, browser profiles, or CLI auth caches.",
        "If installRecommendation.mode is stage-and-merge, install the kit to a temporary folder and merge files manually; do not use -Force without path-level user approval.",
        "After install or merge, fill docs/DOMAIN_GATES.md, docs/PROJECT_CONTEXT.md, and .planning/ACTIVE_CONTEXT_STATE.json, then run scripts/verify-agent-governance.ps1."
    )
}

$outputDir = Split-Path -Parent $OutputPath
if (-not (Test-Path -LiteralPath $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir | Out-Null
}

$json = $report | ConvertTo-Json -Depth 12
[System.IO.File]::WriteAllText($OutputPath, $json, [System.Text.UTF8Encoding]::new($false))

Write-Output "Wrote workspace discovery report to $OutputPath"
Write-Output "Install recommendation: $installMode"
if ($questions.Count -gt 0) {
    Write-Output "Questions for user: $($questions.Count)"
}
