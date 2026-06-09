param(
    [string]$TargetRoot = (Get-Location).Path,
    [switch]$StrictPlaceholders,
    [int]$WarningLimit = 20
)

$ErrorActionPreference = "Stop"
$TargetRoot = [System.IO.Path]::GetFullPath($TargetRoot)
$failures = New-Object System.Collections.Generic.List[string]
$warnings = New-Object System.Collections.Generic.List[string]

function Add-Failure([string]$Message) {
    $failures.Add($Message) | Out-Null
}

function Add-Warning([string]$Message) {
    $warnings.Add($Message) | Out-Null
}

$manifestPath = Join-Path $TargetRoot "KIT_MANIFEST.json"
if (Test-Path -LiteralPath $manifestPath) {
    try {
        $manifest = Get-Content -Raw -LiteralPath $manifestPath | ConvertFrom-Json
        $required = @($manifest.requiredFiles)
        $installFiles = @($manifest.installFiles)
    }
    catch {
        Add-Failure "Invalid KIT_MANIFEST.json ($($_.Exception.Message))"
        $required = @()
        $installFiles = @()
    }
}
else {
    Add-Failure "Missing required governance file: KIT_MANIFEST.json"
    $required = @()
    $installFiles = @()
}

foreach ($relative in $required) {
    $path = Join-Path $TargetRoot $relative
    if (-not (Test-Path -LiteralPath $path)) {
        Add-Failure "Missing required governance file: $relative"
    }
}

foreach ($relative in $installFiles) {
    $path = Join-Path $TargetRoot $relative
    if (-not (Test-Path -LiteralPath $path)) {
        Add-Failure "Manifest install file is missing: $relative"
    }
}

$jsonFiles = @(
    ".agents/AGENT_BOOTSTRAP.json",
    ".agents/startup-profiles.json",
    ".agents/templates/BROKER_BUILD_SPEC.example.json",
    ".agents/templates/MULTIAGENT_RUNTIME_SETTINGS.example.json",
    ".planning/ACTIVE_CONTEXT_STATE.json",
    ".agents/templates/PROJECT_SETTINGS.example.json",
    "KIT_MANIFEST.json"
)

foreach ($relative in $jsonFiles) {
    $path = Join-Path $TargetRoot $relative
    if (Test-Path -LiteralPath $path) {
        try {
            Get-Content -Raw -LiteralPath $path | ConvertFrom-Json | Out-Null
        }
        catch {
            Add-Failure "Invalid JSON: $relative ($($_.Exception.Message))"
        }
    }
}

$bootstrapPath = Join-Path $TargetRoot ".agents/AGENT_BOOTSTRAP.json"
if (Test-Path -LiteralPath $bootstrapPath) {
    try {
        $bootstrap = Get-Content -Raw -LiteralPath $bootstrapPath | ConvertFrom-Json
        if ($bootstrap.purpose -notmatch "Machine-readable") {
            Add-Failure ".agents/AGENT_BOOTSTRAP.json is missing a machine-readable purpose."
        }
        if ($bootstrap.authority.canonical_entrypoint -ne "AGENTS.md") {
            Add-Failure ".agents/AGENT_BOOTSTRAP.json should route canonical authority to AGENTS.md."
        }
        if ($bootstrap.authority.profile_source -ne ".agents/startup-profiles.json") {
            Add-Failure ".agents/AGENT_BOOTSTRAP.json should point at .agents/startup-profiles.json for profiles."
        }
        if ($bootstrap.install_onboarding.discovery_script -ne "scripts/discover-workspace.ps1") {
            Add-Failure ".agents/AGENT_BOOTSTRAP.json should point at scripts/discover-workspace.ps1 for onboarding discovery."
        }
        if (-not @($bootstrap.safety.never).Contains("export_cli_or_browser_auth_cache_material")) {
            Add-Failure ".agents/AGENT_BOOTSTRAP.json is missing the auth/cache export prohibition."
        }
        if ($bootstrap.multiagent_runtime.broker_scripts_bundled -ne $false) {
            Add-Failure ".agents/AGENT_BOOTSTRAP.json should state that broker scripts are not bundled."
        }
        if ($bootstrap.multiagent_runtime.broker_templates_bundled -ne $true) {
            Add-Failure ".agents/AGENT_BOOTSTRAP.json should state that broker templates are bundled."
        }
        if ($bootstrap.multiagent_runtime.readiness_script -ne "scripts/check-agent-runtimes.ps1") {
            Add-Failure ".agents/AGENT_BOOTSTRAP.json should point at scripts/check-agent-runtimes.ps1."
        }
        if ($bootstrap.multiagent_runtime.broker_scaffold_script -ne "scripts/scaffold-multiagent-brokers.ps1") {
            Add-Failure ".agents/AGENT_BOOTSTRAP.json should point at scripts/scaffold-multiagent-brokers.ps1."
        }
        if ($bootstrap.multiagent_runtime.broker_build_guide -ne "docs/MULTIAGENT_BROKER_BUILD_GUIDE.md") {
            Add-Failure ".agents/AGENT_BOOTSTRAP.json should point at docs/MULTIAGENT_BROKER_BUILD_GUIDE.md."
        }
        if ($bootstrap.multiagent_runtime.macos_linux_port_required_before_use -ne $true) {
            Add-Failure ".agents/AGENT_BOOTSTRAP.json should require macOS/Linux runtime porting before use."
        }
    }
    catch {
        Add-Failure "Could not evaluate .agents/AGENT_BOOTSTRAP.json ($($_.Exception.Message))"
    }
}

$agentsPath = Join-Path $TargetRoot "AGENTS.md"
if (Test-Path -LiteralPath $agentsPath) {
    $agents = Get-Content -Raw -LiteralPath $agentsPath
    if ($agents -notmatch '<a name="hard-stops"></a>') {
        Add-Failure "AGENTS.md is missing the hard-stops anchor."
    }
    if ($agents -notmatch 'SAFETY CHECKSUM') {
        Add-Failure "AGENTS.md is missing the bottom SAFETY CHECKSUM."
    }
    if ($agents -notmatch 'git add \.' -or $agents -notmatch 'git add -A') {
        Add-Failure "AGENTS.md should explicitly forbid blanket staging."
    }
    if ($agents -notmatch 'No auth/cache export' -or $agents -notmatch 'CLI profiles' -or $agents -notmatch 'browser profiles' -or $agents -notmatch 'auth caches') {
        Add-Failure "AGENTS.md is missing the auth/cache export hard stop."
    }
}

$multiagentSkillPath = Join-Path $TargetRoot ".agents/skills/multiagent-coordination/SKILL.md"
if (Test-Path -LiteralPath $multiagentSkillPath) {
    $multiagentSkill = Get-Content -Raw -LiteralPath $multiagentSkillPath
    if ($multiagentSkill -notmatch 'Do not include local CLI profiles' -or $multiagentSkill -notmatch 'browser profiles' -or $multiagentSkill -notmatch 'auth caches') {
        Add-Failure "multiagent-coordination/SKILL.md is missing the auth/cache exclusion policy."
    }
    if ($multiagentSkill -notmatch 'does not bundle a CLI broker' -or $multiagentSkill -notmatch 'Windows-first PowerShell' -or $multiagentSkill -notmatch 'macOS or Linux') {
        Add-Failure "multiagent-coordination/SKILL.md is missing the generic runtime/porting disclosure."
    }
    if ($multiagentSkill -notmatch 'multiagent-broker-build') {
        Add-Failure "multiagent-coordination/SKILL.md should route broker construction through multiagent-broker-build."
    }
}

$multiagentEvidencePath = Join-Path $TargetRoot ".agents/skills/multiagent-coordination/references/evidence-packets.md"
if (Test-Path -LiteralPath $multiagentEvidencePath) {
    $multiagentEvidence = Get-Content -Raw -LiteralPath $multiagentEvidencePath
    if ($multiagentEvidence -notmatch '## Never Include' -or $multiagentEvidence -notmatch 'auth caches' -or $multiagentEvidence -notmatch 'API keys') {
        Add-Failure "multiagent evidence packet reference is missing the auth/cache never-include section."
    }
}

$multiagentRoutingPath = Join-Path $TargetRoot ".agents/skills/multiagent-coordination/references/routing.md"
if (Test-Path -LiteralPath $multiagentRoutingPath) {
    $multiagentRouting = Get-Content -Raw -LiteralPath $multiagentRoutingPath
    if ($multiagentRouting -notmatch 'Do not route credential' -or $multiagentRouting -notmatch 'auth-cache' -or $multiagentRouting -notmatch 'browser-profile') {
        Add-Failure "multiagent routing reference is missing the sensitive-auth local-only rule."
    }
}

$profilesPath = Join-Path $TargetRoot ".agents/startup-profiles.json"
if (Test-Path -LiteralPath $profilesPath) {
    try {
        $profiles = Get-Content -Raw -LiteralPath $profilesPath | ConvertFrom-Json
        $caps = $profiles.fileCaps
        if ($caps) {
            $caps.PSObject.Properties | ForEach-Object {
                $relative = $_.Name
                $cap = $_.Value
                $path = Join-Path $TargetRoot $relative
                if (Test-Path -LiteralPath $path) {
                    $text = Get-Content -Raw -LiteralPath $path
                    $words = (($text -split '\s+') | Where-Object { $_ }).Count
                    $bytes = (Get-Item -LiteralPath $path).Length
                    if ($cap.maxWords -and $words -gt [int]$cap.maxWords) {
                        Add-Failure "File exceeds maxWords cap: $relative ($words > $($cap.maxWords))"
                    }
                    if ($cap.failBytes -and $bytes -gt [int]$cap.failBytes) {
                        Add-Failure "File exceeds failBytes cap: $relative ($bytes > $($cap.failBytes))"
                    }
                }
            }
        }
    }
    catch {
        Add-Failure "Could not evaluate startup profile caps ($($_.Exception.Message))"
    }
}

$scanFiles = @($installFiles | Where-Object {
    ($_ -match '\.(md|json|ps1|txt|mjs)$') -and
    ($_ -notmatch '^KIT_MANIFEST\.json$')
})
$projectSpecificTerms = @(
    ("Clear" + "Route"),
    ("clear" + "route"),
    ("GOV" + "\.UK"),
    ("O" + "ISC"),
    ("I" + "AA"),
    ("Project " + "2\.0"),
    ("Platform " + "2\.0"),
    ("D" + "8"),
    ("D" + "9"),
    ("Sup" + "abase"),
    ("legal" + "-platform")
) -join "|"

$sensitiveLocalPathPattern = @(
    '(?:^|[\\/])AppData[\\/](?:Local|Roaming)(?:[\\/]|$)',
    '(?:^|[\\/])\.gemini(?:[\\/]|$)',
    '(?:^|[\\/])\.claude(?:[\\/]|$)',
    '(?:^|[\\/])\.codex(?:[\\/]|$)',
    '(?:^|[\\/])\.config[\\/]gh(?:[\\/]|$)',
    '(?:^|[\\/])\.aws(?:[\\/]|$)',
    '(?:^|[\\/])\.azure(?:[\\/]|$)',
    '(?:^|[\\/])\.ssh(?:[\\/]|$)',
    '(?:^|[\\/])cookies\.sqlite$',
    '(?:^|[\\/])Login Data$',
    '(?:^|[\\/])Local State$'
) -join '|'

$credentialLeakPattern = @(
    '-----BEGIN (?:RSA |OPENSSH |EC |DSA |PRIVATE )?KEY-----',
    '(?i)\b(?:api[_-]?key|access[_-]?token|refresh[_-]?token|session[_-]?cookie|client[_-]?secret)\s*[:=]\s*["''][^"'']+',
    "(?i)$sensitiveLocalPathPattern"
) -join '|'

foreach ($relative in $scanFiles) {
    $path = Join-Path $TargetRoot $relative
    if (Test-Path -LiteralPath $path) {
        $matches = Select-String -LiteralPath $path -Pattern $projectSpecificTerms -AllMatches
        foreach ($match in $matches) {
            Add-Failure "Project-specific term remains in ${relative}:$($match.LineNumber)"
        }
        $credentialMatches = Select-String -LiteralPath $path -Pattern $credentialLeakPattern -AllMatches
        foreach ($match in $credentialMatches) {
            Add-Failure "Credential/cache leakage pattern in ${relative}:$($match.LineNumber)"
        }
    }
}

$placeholderPattern = '\[(?:PROJECT_NAME|YYYY-MM-DD|DEFAULT_BRANCH|owner|link|path|topic|cadence|fill in|project [^\]]+|command|URL or owner doc|npm\|pnpm\|yarn\|uv\|poetry\|cargo\|go\|other|node\|python\|other)[^\]]*\]'
$placeholderScanFiles = @(
    $installFiles | Where-Object {
        ($_ -match '\.(md|json)$') -and
        ($_ -notmatch '^\.agents/templates/') -and
        ($_ -notmatch '^KIT_MANIFEST\.json$')
    }
)

foreach ($relative in $placeholderScanFiles) {
    $path = Join-Path $TargetRoot $relative
    if (Test-Path -LiteralPath $path) {
        $matches = Select-String -LiteralPath $path -Pattern $placeholderPattern -AllMatches
        foreach ($match in $matches) {
            $message = "Unresolved placeholder in ${relative}:$($match.LineNumber)"
            if ($StrictPlaceholders) {
                Add-Failure $message
            }
            else {
                Add-Warning $message
            }
        }
    }
}

if ($failures.Count -gt 0) {
    Write-Output "VERIFY_FAIL"
    $failures | ForEach-Object { Write-Output "- $_" }
    exit 1
}

Write-Output "VERIFY_OK"
if ($warnings.Count -gt 0) {
    Write-Output "VERIFY_WARNINGS ($($warnings.Count) unresolved placeholder warning(s); run with -StrictPlaceholders after customisation to make these failures)"
    $warnings | Select-Object -First $WarningLimit | ForEach-Object { Write-Output "- $_" }
    if ($warnings.Count -gt $WarningLimit) {
        Write-Output "- ... $($warnings.Count - $WarningLimit) more warning(s) omitted"
    }
}
