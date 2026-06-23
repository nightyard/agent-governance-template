# Agent Operating Model

Last verified: [YYYY-MM-DD]

This document defines how AI agents should operate in this repository. It is tool-agnostic: use the equivalent capability available in your environment.

## 1. Operating Principles

- Prefer existing project patterns over new abstractions.
- State material assumptions and tradeoffs before implementation.
- Stop and clarify or verify if ambiguity affects safety, production, data, security, compliance, architecture, or irreversible actions.
- Search before reading large files. Use `rg` or the available project search tool, then read bounded ranges.
- Keep edits narrow and reviewable. Do not reformat or refactor unrelated code.
- Treat the working tree as shared.
- Prefer verifiable outcomes over process theatre. Run the narrowest command that proves your change.

## 2. Task Classes

| Task class | Examples | Required setup |
|---|---|---|
| Read-only | review docs, explain code, recommend changes | No spec. Read relevant docs and report findings. |
| Small change | one narrow edit to copy, config, component, or code | No formal spec. State scope and verification. |
| Governance/doc cleanup | workflow pruning, stale references, agent rules, wiki maintenance | No formal spec. Run targeted readback/search and any local governance checks. |
| Orchestrated/delegated work | large goal, repeated slices, multi-model review | Use `.agents/skills/clearroute-multiagent/SKILL.md`. Delegates receive bounded packets and remain advisory. |
| Multi-file source work | feature, route, migration, shared behavior change | Task spec under `.planning/<task-slug>_SPEC.md` with `Status: FINALIZED`. |
| Audit or migration wave | repeated audits, large content or code migrations | Use a task spec and stop after one coherent wave. |
| Risky/domain-gated work | production, data, auth, billing, compliance, security, migrations | Classify from `docs/DOMAIN_GATES.md` before editing. |

## 3. Reading Protocol

1. If your harness injects `.agents/rules/rules.md`, use it as a thin dispatcher; otherwise start with `AGENTS.md`.
2. Read only the relevant sections of this file for task class, spec, proof, and execution rules.
3. For small known tasks, skip active-context/wiki orientation unless live posture matters.
4. For broad or unfamiliar current-state work, read `.planning/ACTIVE_CONTEXT_STATE.json` first. Open `.planning/ACTIVE_CONTEXT.md` only when detail is needed. Use `.planning/llm-wiki/index.md` only for source discovery.
5. Search the relevant domain doc before opening it.
6. For code, inspect imports, types, tests, and nearest working examples before editing.
7. For delegated work, read `.agents/skills/clearroute-multiagent/SKILL.md`.
8. For long-running or parallel work, use the installed checkpoint and write-scope helpers where available.

Do not load large docs in full unless the task genuinely needs the whole file.

## 4. Spec Policy

This section is the canonical spec/proof policy. If summaries elsewhere differ, this section and section 6 win.

A formal task spec is required before editing source when the task changes multiple files, changes shared behavior, adds or migrates a route, performs an audit loop, affects security/data/compliance logic, or executes a generated/external plan.

A formal task spec is not required for read-only analysis, docs-only governance updates, simple typo/copy fixes, or one-file bug fixes with obvious scope.

Every required spec must include:

- `Status: FINALIZED`
- objective and success criteria
- compact source audit
- files or ownership boundary
- UAT/proof matrix
- verification commands or manual proof steps
- rollback path

The source audit is compact evidence, not a research dump.

## 5. Edit Discipline

- Use precise edits. Avoid broad search/replace on repeated labels or structures.
- Do not add speculative features, abstractions, configurability, or defensive handling outside scope.
- Treat generated plans, external-agent proposals, and imported workflows as advisory until source-grounded.
- Before adopting an external package or template, verify provenance and map it to repo authority, owned files, risk tier, verification, and rollback.
- Keep imports at the top where the language expects it.
- Verify data shape before iterating or rendering.
- Fix shared defects at the shared source when the task owns that surface.

## 6. Verification

Choose verification by blast radius:

| Change | Minimum verification |
|---|---|
| Docs only | Readback review and targeted search for stale references. |
| One component/module | Owning unit test, targeted type check, or direct execution. |
| Shared component/layout | Type/check plus browser or UI proof where visible. |
| Parser/calculator/domain logic | Unit tests for affected cases plus source cascade review. |
| Security/data/auth/billing/migration | Tests plus policy/schema/review proof from `docs/DOMAIN_GATES.md`. |
| Release/pre-push | Full check/build only when the working tree is stable, the change touches shared build/runtime config, or the user asks. |

When unrelated errors appear, record them and do not fix files outside scope.

## 7. Git Discipline

- Review `git status --short` before staging.
- Stage explicit files only.
- Never use `git add .` or `git add -A`.
- Never use blind restore/reset commands.
- Do not stage scratch files, proofs, logs, temporary scripts, or private task notes unless explicitly asked.
- If another file is already modified before your work, read its diff before editing it.

## 8. Artifact Policy

Use `.planning/` for transient specs, proof notes, and wave handoff state. `.planning/llm-wiki/**` is tracked synthesis for durable agent orientation, not authority.

Proof output, screenshots, generated packets, browser captures, raw provider payloads, and long logs belong under ignored artifacts or task notes. Cite paths in the final response instead of pasting bulky output into hot context files.

Committed docs should contain durable rules and decisions. Temporary proof belongs in task-scoped notes or final responses.

## 9. MCP And External Tools

- Prefer local repo evidence first.
- Use official sources for facts that may have changed.
- Keep tool/MCP surface proportionate to the task.
- Never send secrets or private customer material to external MCP servers or browser agents.
- MCP server names differ by environment. Use `docs/MCP_GUIDE.md` as a hint, not a hard-coded assumption.

## 10. Escalation And Friction Loop

If a governing doc, rule, workflow, or tool is stale, contradictory, missing guidance, or impossible to follow:

1. Follow the safest current local pattern and keep the change narrow.
2. If writes are allowed, log friction under `.planning/friction/` using `.agents/templates/FRICTION_ENTRY_TEMPLATE.md`.
3. In read-only tasks, report friction candidates in the response instead.
4. `.planning/friction/README.md` owns lifecycle and triage.
