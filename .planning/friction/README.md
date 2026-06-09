# Friction Log

The friction log is the iterative-improvement loop for the agentic system. Any agent that hits friction with governing docs, rules, workflows, or tooling records it here with enough context for a reviewer to improve the system.

## Scope

Log friction with:

- repo governance: `AGENTS.md`, `.agents/rules/rules.md`, workflows, templates, or docs;
- tooling/orchestration: MCP servers, CLI/browser agents, packet schemas, verification scripts, or context/search behavior.

Out of scope: one-off task notes, proof logs, private data, raw provider payloads, or details that no future agent would re-encounter.

## When To Log

Log whenever a doc, rule, workflow, or tool made you take a wrong turn, cost meaningful time, produced a near miss, or would predictably trip the next agent.

In read-only tasks, report friction candidates in the response instead of writing a new entry.

## How To Log

1. Copy `.agents/templates/FRICTION_ENTRY_TEMPLATE.md` to `.planning/friction/YYYY-MM-DD-kebab-slug.md`.
2. Fill the sections above the triage divider.
3. Leave `Status: open`.
4. Continue the in-flight task; logging should not block delivery.

## Lifecycle

`open` -> `triaged` -> `landed` | `declined`

- `open`: logged by the agent that hit the friction.
- `triaged`: a bounded fix has been proposed or applied and awaits verification.
- `landed`: verified and accepted.
- `declined`: reviewed and intentionally not changed.

## Authority

This loop cannot approve production, data, security, compliance, release, or destructive decisions. Those remain governed by `docs/DOMAIN_GATES.md` and the user/owner.
