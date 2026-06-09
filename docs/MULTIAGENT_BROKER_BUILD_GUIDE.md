# Multiagent Broker Build Guide

Last verified: [YYYY-MM-DD]

Use this after `docs/MULTIAGENT_RUNTIME_SETUP.md`. The kit provides generic broker templates and a scaffold script; the target project owns the final runtime.

## What Gets Built

`scripts/scaffold-multiagent-brokers.ps1` copies these project-owned starter files:

- `scripts/multiagent-broker.mjs` - facade for packet, CLI, browser, and dev-server surfaces.
- `scripts/build-multiagent-evidence-packet.mjs` - creates source-grounded packets with redaction and bounded excerpts.
- `scripts/cli-delegate-broker.mjs` - runs configured local CLI agents from `.agents/runtime/MULTIAGENT_RUNTIME_SETTINGS.json`.
- `scripts/browser-agent-broker.mjs` - runs a configured browser automation command, or reports that browser runtime is not configured.
- `scripts/dev-server-broker.mjs` - checks or starts a configured local dev server.
- `.agents/runtime/MULTIAGENT_BROKER_BUILD.json` - local build checklist.

These are starter brokers. They are not private project brokers and contain no provider credentials or browser profile paths.

## Build Workflow

1. Confirm the target OS.
2. On macOS or Linux, port the Windows-first PowerShell scaffolding and any process/browser/dev-server commands before enabling runtime use.
3. Run:

   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\scaffold-multiagent-brokers.ps1 -TargetRoot "."
   ```

4. Copy `.agents/templates/MULTIAGENT_RUNTIME_SETTINGS.example.json` to `.agents/runtime/MULTIAGENT_RUNTIME_SETTINGS.json` if it does not already exist.
5. Enable only user-selected CLI/browser agents.
6. Configure each selected CLI with:
   - `command`;
   - `versionArgs`;
   - optional non-secret `statusArgs`;
   - `delegateArgsTemplate` using `{{packetPath}}`, `{{packetText}}`, and `{{taskId}}`.
7. Configure browser agents only when a project-owned browser automation command exists. Use `launchCommandTemplate` with `{{url}}`, `{{packetPath}}`, `{{packetText}}`, and `{{taskId}}`.
8. Configure `devServer.command` and `devServer.url` only when local dev-server helpers are wanted.
9. Run readiness:

   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\check-agent-runtimes.ps1 -TargetRoot "."
   ```

10. Ask the user to sign in only after readiness or visible browser checks prove a selected runtime is not signed in.
11. Test broker status:

   ```powershell
   node .\scripts\multiagent-broker.mjs status
   node .\scripts\multiagent-broker.mjs cli status
   node .\scripts\multiagent-broker.mjs browser status
   node .\scripts\multiagent-broker.mjs dev status
   ```

12. Build a packet:

   ```powershell
   node .\scripts\multiagent-broker.mjs packet --objective "read-only governance smoke test" --task-id "broker-smoke" --source "AGENTS.md" --out-dir ".\agent-handoffs\broker-smoke"
   ```

13. Run one read-only CLI or browser round trip only after the selected runtime is configured.

## Required Broker Contract

All broker surfaces should return JSON for status and task completion, with:

- `ok`;
- `status` or `error`;
- selected agent/provider id;
- artifact path when output is written;
- exit code or readiness state;
- no secrets, cookies, tokens, private keys, auth caches, or private customer data.

Delegate output is advisory. The primary agent must verify claims against local sources before editing or reporting completion.

## Porting Notes

Porting is required before use on macOS or Linux when any helper assumes Windows PowerShell, Windows process behavior, or Windows path quoting.

Port:

- `scripts/scaffold-multiagent-brokers.ps1` or provide a shell equivalent;
- process spawn, detach, timeout, and wait behavior;
- shell quoting and path normalization;
- lock/concurrency files;
- browser automation launch commands;
- dev-server start/status/stop commands.

Document the ported commands in `.agents/runtime/MULTIAGENT_BROKER_BUILD.json` and prove them with a read-only packet.
