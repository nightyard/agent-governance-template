---
description: Select, sign in, port, and verify optional CLI/browser agents for the generic multiagent skill.
---

# Multiagent Runtime Setup

Use this before enabling CLI or browser delegation from `.agents/skills/multiagent-coordination/SKILL.md`.

## Steps

1. Read `docs/MULTIAGENT_RUNTIME_SETUP.md`.
2. Detect OS. If it is not Windows, stop and port broker/CLI/browser/dev-server runtime helpers before use.
3. Ask the user which CLI agents and browser agents to enable.
4. Copy `.agents/templates/MULTIAGENT_RUNTIME_SETTINGS.example.json` to `.agents/runtime/MULTIAGENT_RUNTIME_SETTINGS.json` and enable only selected agents.
5. Run `scripts/check-agent-runtimes.ps1` before asking for any sign-in.
6. For missing CLIs, ask whether to install or deselect.
7. For failed CLI status checks, ask the user to run the provider's interactive login flow, then rerun the readiness script.
8. For browser agents, open the provider URL using browser automation and inspect visible UI state only.
9. If the browser provider shows a login page, ask the user to sign in interactively, then re-check.
10. Wire project-owned broker/adapters and verify a read-only packet round trip before allowing delegate work.

## Exit Criteria

- enabled agents are recorded in `.agents/runtime/MULTIAGENT_RUNTIME_SETTINGS.json`;
- `.planning/onboarding/agent-runtime-readiness.local.json` exists;
- browser agents have visible sign-in proof, not cache proof;
- OS-specific broker/CLI/browser helper commands are documented;
- a read-only multiagent packet test has passed.
