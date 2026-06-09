# Generic Agent Governance Template

This folder is a portable starter governance set for Codex and other agentic IDEs. It is distilled from a working multi-agent repository, with project-specific product, legal, brand, and launch rules removed.

Use it to give agents:

- one canonical entrypoint (`AGENTS.md`);
- thin tool dispatchers (`CLAUDE.md`, `GEMINI.md`, `.agents/rules/rules.md`);
- bounded startup profiles;
- a GSD-inspired planning workflow;
- source-audited specs for larger changes;
- explicit verification and Git hygiene;
- lightweight write-scope, checkpoint, and friction-close helper scripts;
- a friction loop for improving the rules over time;
- a lightweight LLM wiki for source discovery, not authority;
- a generic multi-agent coordination skill.

## Install

From a cloned copy:

```powershell
git clone https://github.com/nightyard/agent-governance-template.git
cd agent-governance-template
```

Then run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\install.ps1 -TargetRoot "C:\path\to\friend\repo" -ProjectName "FriendProject" -LastVerifiedDate "2026-06-09" -DefaultBranch "main"
```

The installer refuses to overwrite existing files unless `-Force` is supplied. Review `docs/DOMAIN_GATES.md` and replace the placeholders before serious work.

After install, from the target repo:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\verify-agent-governance.ps1
```

Use `-StrictPlaceholders` on the verifier after the friend has finished customising owner names, sources, and commands.

## What To Customise First

Read `docs/ADOPTION_GUIDE.md` first. At minimum:

1. Replace `[PROJECT_NAME]`, owner names, default branch, package manager, and verification commands.
2. Fill `docs/DOMAIN_GATES.md` with real production, data, security, compliance, and release hard stops.
3. Fill `docs/PROJECT_CONTEXT.md` and `.planning/ACTIVE_CONTEXT_STATE.json` with the current project posture.
4. Review `.agents/templates/GITIGNORE_SNIPPET.txt` and `.agents/templates/IGNORE_SNIPPET.txt` for generated agent artifacts.
5. Update `.agents/startup-profiles.json` if your project has different hot files or context budgets.
6. Copy `.agents/templates/PROJECT_SETTINGS.example.json` to a project-owned config if a machine-readable settings file would help.
7. Add domain skills or workflows under `.agents/skills/` and `.agents/workflows/`, then list them in the indexes.

## Design Intent

Keep the always-read path small. Use `AGENTS.md` for durable hard stops and routing, `.planning/ACTIVE_CONTEXT_STATE.json` for live posture, and `.planning/llm-wiki/` only as a source map. Large logs, screenshots, generated packets, and provider payloads belong in ignored artifacts, not in hot context files.

`KIT_MANIFEST.json` is the package inventory. The installer and verifier read it so the copied file set cannot silently drift.
