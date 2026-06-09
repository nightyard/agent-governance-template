---
description: Cold-start path selector for agents. Read AGENTS.md first, then pick a path and context budget.
---

# Agent Onboarding

For cold starts, unfamiliar work, or broad current-state tasks. Read `AGENTS.md` first; this file only adds path and budget choices.

## Fast Path Selector

| Path | Use when | Minimal context |
|---|---|---|
| Direct | Small, known, one-file, sensitive, or tightly coupled task | `AGENTS.md`, nearest source anchor |
| GSD planning | Goal is broad, ambiguous, or needs a plan before edits | `.agents/workflows/gsd-planning.md`, then task sources |
| Multi-agent | Scope is large enough for parallel/sub-agent review or the user asks for a panel | `.agents/skills/multiagent-coordination/SKILL.md` |
| Current-state | Live posture, release readiness, blockers, or roadmap matters | `.planning/ACTIVE_CONTEXT_STATE.json`, then `.planning/ACTIVE_CONTEXT.md` only if detail is needed |
| Governance | Agent rules, workflows, context budgets, or source maps are in scope | `docs/AGENT_OPERATING_MODEL.md`, `docs/WORKFLOW_PROTOCOL.md`, `.planning/llm-wiki/pages/governance/rules-and-workflows.md` |

## Token Budget

- Search first with `rg -n`; read 40-80 line windows around matching anchors.
- Do not full-read large docs unless the task is an explicit document audit.
- Use `.planning/llm-wiki/index.md` for source discovery only; verify through linked sources.
- Keep `.planning/ACTIVE_CONTEXT.md` for volatile state. Store raw logs and proof in task artifacts instead.

## Exit To Work

Before editing, know the task class, owned files, governing source, risk tier, whether `.planning/<task-slug>_SPEC.md` is required, and the narrowest useful verification command.
