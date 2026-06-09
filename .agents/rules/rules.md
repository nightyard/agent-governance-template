# [PROJECT_NAME] Agent Rules

Last verified: [YYYY-MM-DD]

Thin injected dispatcher. `AGENTS.md` is the canonical governance doc; this file only routes agents there fast.

[SAFETY CHECKSUM: read `AGENTS.md#hard-stops` before acting. Preserve dirty worktrees; stage explicit paths only; production/external effects gated; current authoritative sources win; no secrets/private data to external tools.]

## Start Path

1. Read `AGENTS.md`: Hard Stops, Startup Profiles, Source Hierarchy.
2. If machine routing is needed, parse `.agents/AGENT_BOOTSTRAP.json`; exact profile files/budgets live in `.agents/startup-profiles.json`.
3. For production, data, security, auth, billing, compliance, regulated copy, migrations, infrastructure, or shared-seam work, classify the risk from `docs/DOMAIN_GATES.md` before editing.
4. Read only the task-relevant governing source. Search with `rg`, then bounded ranges. Workflow discovery: `.agents/WORKFLOWS_INDEX.md`; skill discovery: `.agents/skills/INDEX.md`; repeated friction: `.planning/friction/README.md`.

## State Hygiene

Never dump raw logs, stack traces, provider payloads, or command output into active context or always-read files. Keep `.planning/ACTIVE_CONTEXT.md` compact; link task notes or artifacts instead.
