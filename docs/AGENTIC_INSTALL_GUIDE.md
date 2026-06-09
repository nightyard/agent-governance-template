# Agentic Install Guide

Last verified: [YYYY-MM-DD]

Use this when an AI agent is installing the kit into an existing workspace. The agent should infer everything it safely can from the repo before asking the user for missing decisions.

## Copy-Paste Prompt For The Installing Agent

```text
Install the generic agent governance kit into this workspace.

First clone or open https://github.com/nightyard/agent-governance-template. Read `.agents/AGENT_BOOTSTRAP.json` for machine-readable routing. Before copying files, run its workspace discovery script against this repo:

powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\discover-workspace.ps1 -TargetRoot "<absolute path to this repo>"

Read the generated workspace-discovery.local.json report. Use existing AGENTS/CLAUDE/GEMINI/Cursor/Windsurf/GitHub Copilot rules, README/docs, package files, CI files, and inferred test commands where available. Ask me only for the missing decisions listed in the report, especially domain hard stops, private-data policy, owners, current phase, production status, unresolved install conflicts, and which CLI/browser agents I want set up.

Before asking me to sign into any selected CLI or browser agent, test readiness first. Use scripts/check-agent-runtimes.ps1 for CLI checks and visible browser UI checks for browser agents. If I am not signed in, ask me to complete the provider's interactive sign-in flow, then re-test. Do not ask for secrets. Do not read or export .env files, private keys, cookies, browser profiles, CLI auth caches, token stores, or machine-specific credential paths. Do not run install.ps1 -Force unless you list the exact overwritten paths and I approve them.

If no target files conflict, run install.ps1 with the inferred project name, date, and default branch. If files conflict, install the kit to a temporary staging folder and merge it into the repo while preserving existing rules. Then fill docs/DOMAIN_GATES.md, docs/PROJECT_CONTEXT.md, .planning/ACTIVE_CONTEXT_STATE.json, and AGENTS.md from discovered sources plus my answers. If I want multiagent delegation, use docs/MULTIAGENT_RUNTIME_SETUP.md and docs/MULTIAGENT_BROKER_BUILD_GUIDE.md to scaffold project-owned brokers and run a read-only packet round trip. If the environment is macOS or Linux, port Windows-first broker, CLI, browser, and dev-server helpers before marking multiagent delegation usable. Finish by running scripts/verify-agent-governance.ps1 and report changed files, runtime readiness, broker readiness, and remaining placeholders.
```

## Installer Workflow

1. Identify the target repo root and confirm you are not operating inside the kit repo by mistake.
2. Parse `.agents/AGENT_BOOTSTRAP.json`, then run `scripts/discover-workspace.ps1` from the kit repo against the target repo.
3. Read the discovery report and the listed existing rules/docs with bounded reads.
4. Infer:
   - project name;
   - default branch;
   - package manager and runtime;
   - likely verification commands;
   - existing agent surfaces and rule files;
   - CI/task-runner files;
   - production, data, deployment, or migration risk hints by path only.
5. Ask the user only for missing or low-confidence decisions.
6. Ask which optional CLI agents and browser agents to set up.
7. Install directly only when the report says `direct-install`.
8. If the report says `stage-and-merge`, install to a temporary folder and merge manually. Preserve existing hard stops unless the user explicitly retires them.
9. Update required files:
   - `AGENTS.md`;
   - `docs/DOMAIN_GATES.md`;
   - `docs/PROJECT_CONTEXT.md`;
   - `.planning/ACTIVE_CONTEXT_STATE.json`;
   - `.planning/ACTIVE_CONTEXT.md`;
   - `.agents/startup-profiles.json` if the repo has different hot files.
10. For selected CLI/browser agents, follow `docs/MULTIAGENT_RUNTIME_SETUP.md`.
11. Build or scaffold project-owned brokers with `docs/MULTIAGENT_BROKER_BUILD_GUIDE.md`.
12. On macOS or Linux, port Windows-first broker/CLI/browser/dev-server runtime helpers before enabling multiagent delegation.
13. Run the verifier. Use `-StrictPlaceholders` only after owner/project placeholders are actually resolved.

## What The Discovery Script Does

The script writes `.planning/onboarding/workspace-discovery.local.json` by default. That file is local working context, not durable governance.

It safely gathers:

- existing agent and IDE rule files;
- common project docs;
- package/runtime files;
- CI workflow files;
- inferred branch, package manager, runtime, and likely verification commands;
- kit install conflicts;
- a short list of questions the user must answer.

It avoids reading obvious secret files and redacts common secret assignment shapes in excerpts. Treat the report as local-only unless the user explicitly approves sharing it.
