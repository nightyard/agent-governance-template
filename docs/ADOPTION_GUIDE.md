# Adoption Guide

Last verified: [YYYY-MM-DD]

Use this once when installing the kit into a new repository, then keep `AGENTS.md` and the governing docs current.

## 1. Agentic Preflight

When an AI agent is doing the install, start with `.agents/AGENT_BOOTSTRAP.json` and `docs/AGENTIC_INSTALL_GUIDE.md`.

From the kit folder, run discovery against the target repo before copying files:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\discover-workspace.ps1 -TargetRoot "C:\path\to\repo"
```

The installing agent should read the generated `.planning/onboarding/workspace-discovery.local.json`, infer what it can from existing rules/docs/tooling, and ask the user only for missing decisions.

If CLI/browser delegates are desired, follow `docs/MULTIAGENT_RUNTIME_SETUP.md`. The generic kit includes coordination rules, not a ready-made broker runtime.

## 2. Install

Run from the template folder:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\install.ps1 -TargetRoot "C:\path\to\repo" -ProjectName "MyProject" -LastVerifiedDate "2026-06-09" -DefaultBranch "main"
```

Use `-Force` only after reviewing what would be overwritten.

## 3. Customize Required Placeholders

Replace:

- `[PROJECT_NAME]`
- `[YYYY-MM-DD]`
- owner names and default branch
- package manager and runtime
- verification commands
- domain risk owners and approved sources

The kit intentionally starts conservative: production, data, security, billing, dependencies, destructive migrations, and external effects are gated until `docs/DOMAIN_GATES.md` says otherwise.

## 4. Set Search And Git Hygiene

Append `.agents/templates/GITIGNORE_SNIPPET.txt` to `.gitignore` if the repo does not already ignore generated agent artifacts. Append `.agents/templates/IGNORE_SNIPPET.txt` to `.ignore` if `rg` or local search is pulling in generated proof bundles.

Do not hide hot entrypoints such as `AGENTS.md`, `.agents/rules/rules.md`, or `.planning/ACTIVE_CONTEXT_STATE.json`.

## 5. Fill Current State

Update:

- `docs/PROJECT_CONTEXT.md`
- `docs/DOMAIN_GATES.md`
- `.planning/ACTIVE_CONTEXT.md`
- `.planning/ACTIVE_CONTEXT_STATE.json`
- `docs/KNOWLEDGE.md`

Keep active context compact. Put raw logs, screenshots, and generated packets in ignored artifact folders.

## 6. Verify

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\verify-agent-governance.ps1
```

The verifier checks required files, JSON validity, hard-stop structure, blanket-staging prohibitions, file-cap drift, and legacy project-specific leakage.

After all placeholders are customised, run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\verify-agent-governance.ps1 -StrictPlaceholders
```

## 7. Operate

- Start agents at `AGENTS.md`.
- Use GSD planning for ambiguous goals.
- Create specs with `scripts/new-agent-spec.ps1`.
- Log governance/tooling friction with `scripts/new-agent-friction.ps1`.
- Use `scripts/claim-scope.ps1`, `scripts/release-scope.ps1`, and `scripts/record-checkpoint.ps1` for parallel or long-running work.
- Close friction entries with `scripts/land-agent-friction.ps1` after verification.
- Keep delegates advisory until locally verified.
