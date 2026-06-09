---
description: Agentic installation workflow for adapting this governance kit to an existing workspace.
---

# Install Onboarding

Use this when an agent is asked to install the governance kit into a repo it did not already know.

## Goal

Infer what can be inferred from the workspace, preserve existing rules, ask the user only for missing decisions, and leave the repo with verified, project-specific governance.

## Steps

1. Run the discovery script from the kit repo:

   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\discover-workspace.ps1 -TargetRoot "<target repo>"
   ```

2. Read `.planning/onboarding/workspace-discovery.local.json` plus the listed governance/docs using bounded reads.
3. Use medium/high confidence inferred values without asking the user again.
4. Ask the user only for:
   - domain hard stops and approval gates;
   - private-data and external-tool rules;
   - owner/escalation sources;
   - current phase, production status, and blockers;
   - low-confidence project/default-branch/verification facts;
   - exact handling of existing governance conflicts.
5. If the report says `direct-install`, run `install.ps1` with inferred values.
6. If the report says `stage-and-merge`, install to a temporary folder and merge by hand. Do not use `-Force` without path-level user approval.
7. Fill or merge `AGENTS.md`, `docs/DOMAIN_GATES.md`, `docs/PROJECT_CONTEXT.md`, `.planning/ACTIVE_CONTEXT_STATE.json`, and `.planning/ACTIVE_CONTEXT.md`.
8. Ask which CLI agents and browser agents the user wants to enable. If any are selected, run `.agents/workflows/multiagent-runtime-setup.md`.
9. Run `scripts/verify-agent-governance.ps1`. Run `-StrictPlaceholders` only after customisation is complete.
10. Report changed files, verification output, preserved existing rules, runtime readiness, and remaining user-owned placeholders.

## Safety Rules

- Do not ask for or export secrets, tokens, cookies, private keys, browser profiles, CLI auth caches, or credential paths.
- Do not read `.env` files unless the user explicitly asks for local-only inspection.
- Do not send the discovery report to external delegates without user approval.
- Test selected CLI/browser agents before asking the user to sign in.
- On macOS or Linux, port Windows-first broker/CLI/browser/dev-server runtime scripts before enabling multiagent delegation.
- Existing hard stops remain active until deliberately replaced.
