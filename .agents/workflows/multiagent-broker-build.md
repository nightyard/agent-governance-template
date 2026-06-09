---
description: Build project-owned CLI/browser/dev-server brokers from the generic templates.
---

# Multiagent Broker Build

Use this after runtime choices are known and before `.agents/skills/multiagent-coordination/SKILL.md` delegates any work.

## Steps

1. Read `docs/MULTIAGENT_RUNTIME_SETUP.md` and `docs/MULTIAGENT_BROKER_BUILD_GUIDE.md`.
2. Detect OS. If not Windows, port scaffolding and runtime commands first.
3. Run `scripts/check-agent-runtimes.ps1` before asking for sign-in.
4. Ask the user to sign in only for selected agents that fail readiness or show a browser login page.
5. Run `scripts/scaffold-multiagent-brokers.ps1` without `-Force`.
6. If broker files already exist, list exact paths and ask before overwriting.
7. Customize `.agents/runtime/MULTIAGENT_RUNTIME_SETTINGS.json` with non-secret command templates.
8. Run broker status commands.
9. Build a read-only evidence packet.
10. Run one read-only delegate round trip and verify the result locally.

## Exit Criteria

- project-owned broker scripts exist under `scripts/`;
- `.agents/runtime/MULTIAGENT_RUNTIME_SETTINGS.json` has enabled selected agents only;
- `.agents/runtime/MULTIAGENT_BROKER_BUILD.json` records local broker decisions;
- readiness and status reports pass;
- a read-only packet round trip succeeds;
- no credential, cookie, profile, cache, or token material is copied into the repo.
