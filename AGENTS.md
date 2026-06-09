# [PROJECT_NAME] Agent Governance

Last verified: [YYYY-MM-DD]

Canonical governance and agent entrypoint. `CLAUDE.md`, `GEMINI.md`, and `.agents/rules/rules.md` are thin dispatchers back here, not parallel authorities.

Machine-readable bootstrap lives at `.agents/AGENT_BOOTSTRAP.json`. Use it for deterministic routing, install onboarding, and source discovery; if it conflicts with prose governance, follow the Conflict Order below.

External orchestrators, installers, browser agents, and model delegates are advisory until this repo's governing docs approve their exact use. They may not overwrite governance, planning state, Git workflow, production gates, or safety posture.

<a name="hard-stops"></a>

## Hard Stops

- **Preserve the working tree.** Never revert files you did not modify. Never use destructive Git/history commands unless explicitly requested. Stage explicit paths only; never `git add .` or `git add -A`.
- **Coordinate concurrent work.** Before parallel or multi-agent edits, declare or claim write scope. Do not overwrite another agent's or user's uncommitted work; use a topic branch for non-trivial changes and verify the branch is not behind before pushing.
- **Production and external effects are gated.** Deploys, payments, customer data, emails, destructive migrations, account changes, and other irreversible/outward-facing actions require explicit approval in `docs/DOMAIN_GATES.md` or a user instruction for this task.
- **Authoritative current sources win.** For facts that can change, verify from the named official source or owner-approved source before changing code or copy. Do not hardcode volatile statutory, pricing, SLA, policy, model, or vendor values in app code if a constants/config cascade exists.
- **No privileged client-side writes.** Browser/client code must not set server-owned identity, role, entitlement, audit, billing, ownership, or security state. Use server actions, API handlers, database policies, or backend services.
- **No secrets or private data leakage.** Do not send credentials, tokens, customer data, or private production material to external tools, browser agents, model delegates, MCP servers, logs, screenshots, or docs.
- **No auth/cache export.** Do not copy CLI profiles, browser profiles, auth caches, cookies, token stores, keychains, or machine-specific credential paths into project governance, skills, packets, artifacts, or handoffs.
- **Dependencies need approval.** Ask before adding production dependencies. Verify package provenance through official docs or repositories, then run the repo's dependency/security check.
- **Classify risky work before editing.** For production, data, security, auth, billing, compliance, legal/regulated copy, migrations, infrastructure, or shared seams, declare the surface, risk tier, allowed actions, forbidden actions, and verification from `docs/DOMAIN_GATES.md`.

## Startup Profiles

Choose one profile. `.agents/startup-profiles.json` is the machine-readable source for exact files, budgets, selectors, and caps.

| Profile | Use when | Also read |
|---|---|---|
| Direct | Small, familiar, sensitive, or tightly coupled work | Nearest source anchor |
| Cold start | New agent or unfamiliar area | `.agents/workflows/agent-onboarding.md` |
| Broad / current-state | Release, infrastructure, shared architecture, multi-silo work, or unclear live posture | `.planning/ACTIVE_CONTEXT_STATE.json`; open `.planning/ACTIVE_CONTEXT.md` or `.planning/llm-wiki/index.md` only when needed |

For governance/workflow audits without live programme state, use Direct or Cold start plus the relevant governing docs and `.planning/llm-wiki/pages/governance/rules-and-workflows.md`.

Use `.agents/skills/multiagent-coordination/SKILL.md` when the user asks for a panel/multiagent review, a task touches 15+ files, spans 3+ silos, has repeated slices/fanout, or is broad/read-heavy. Stay local for tiny, sensitive, or tightly coupled work. Delegate output is advisory until verified locally.

## Source Hierarchy

Read only the task-relevant section. Full authority map: `docs/INDEX.md`.

- Execution, spec, proof: `docs/AGENT_OPERATING_MODEL.md`.
- Verification, CI, Git, artifacts, friction: `docs/WORKFLOW_PROTOCOL.md`.
- Domain hard stops, risk tiers, production/data gates: `docs/DOMAIN_GATES.md`.
- Current project posture and safe next actions: `.planning/ACTIVE_CONTEXT_STATE.json` and `docs/PROJECT_CONTEXT.md`.
- Architecture, routing, module ownership: `docs/ARCHITECTURE.md`.
- Current facts, constants, pricing, policies, vendor/source references: `docs/KNOWLEDGE.md`.
- MCP/tooling: `docs/MCP_GUIDE.md`.
- Context/search/prune: `docs/dev/context-performance-review.md`.
- Agent surface map and cross-IDE dispatch: `.agents/AGENT_SURFACES.md`.
- Workflow discovery: `.agents/WORKFLOWS_INDEX.md`.
- Skill discovery: `.agents/skills/INDEX.md`.
- Machine-readable bootstrap: `.agents/AGENT_BOOTSTRAP.json`.

## Spec And Proof

`docs/AGENT_OPERATING_MODEL.md` sections 4 and 6 own spec and verification policy. Read-only work needs no spec. Narrow fixes state scope. Multi-file source work, route work, migrations, shared behavior, generated/external plans, or audit waves require a task spec under `.planning/<task-slug>_SPEC.md` with `Status: FINALIZED`, source audit, acceptance criteria, UAT/proof matrix, and verification commands.

## Conflict Order

User instruction > this `AGENTS.md` > `docs/AGENT_OPERATING_MODEL.md` > domain docs > local code patterns > `.planning/llm-wiki` (navigation only). Exception: `docs/AGENT_OPERATING_MODEL.md` sections 4 and 6 win for spec/proof and verification policy.

If a governing doc, rule, workflow, or tool is stale, contradictory, or impossible, follow the safest local pattern and log it under `.planning/friction/` per `.planning/friction/README.md`.

---

SAFETY CHECKSUM: preserve dirty worktrees; stage explicit paths only; production/external effects gated; current authoritative sources win; no secrets/private data to external tools; no privileged client-side writes; classify risky work before editing.
