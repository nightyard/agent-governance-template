# Workflow Protocol

Last verified: [YYYY-MM-DD]

Practical workflow gates live here. Task classes and spec policy live in `docs/AGENT_OPERATING_MODEL.md`; project-specific high-risk gates live in `docs/DOMAIN_GATES.md`; rule priority lives in `AGENTS.md`.

## 1. Kickoff

1. If `.agents/rules/rules.md` is injected, use it as the thin dispatcher; otherwise start with `AGENTS.md`.
2. Open only relevant `docs/AGENT_OPERATING_MODEL.md` sections for task class, spec, and proof policy.
3. For broad/current-state work, read `.planning/ACTIVE_CONTEXT_STATE.json` first.
4. Search with `rg` before opening large docs; read ranges around relevant anchors.
5. Choose the lightest workflow from `.agents/WORKFLOWS_INDEX.md`.
6. For parallel work, declare or claim write scope before editing. Use `scripts/claim-scope.ps1` / `scripts/release-scope.ps1` when available.

Do not create root scratch files for routine work. Use `.planning/` only when persistent task state or handoff notes are genuinely needed.

## 2. Workflow Map

| Task type | Workflow or source |
|---|---|
| Cold start | `.agents/workflows/agent-onboarding.md` |
| Ambiguous broad goal | `.agents/workflows/gsd-planning.md` |
| Multi-agent coordination | `.agents/skills/multiagent-coordination/SKILL.md`; `.agents/workflows/multi-agent-loop.md` |
| Narrow fact/config correction | `.agents/workflows/cascade-fix.md` |
| Governance/doc cleanup | `docs/AGENT_OPERATING_MODEL.md`, this file, `.planning/friction/README.md` |
| Friction with a doc/rule/tool | `.planning/friction/README.md` |
| Post-work Git | `.agents/workflows/git-commit.md` |
| New task spec | `scripts/new-agent-spec.ps1` |
| New friction entry | `scripts/new-agent-friction.ps1` |
| Long-running checkpoint | `scripts/record-checkpoint.ps1` |
| Write-scope coordination | `scripts/claim-scope.ps1`, `scripts/release-scope.ps1` |
| Close friction entry | `scripts/land-agent-friction.ps1` |

## 3. Definition Of Done

Apply only checks relevant to the task.

| Check | Pass criteria |
|---|---|
| Functionality | Touched behavior renders or executes without known in-scope errors. |
| Type safety | No new in-scope type errors. |
| Architecture | Ownership, layering, routing, and module boundaries are preserved. |
| Plan/source grounding | Generated, delegated, or external plans satisfy the compact source-audit checklist before execution. |
| Dependencies | New packages have provenance, approval, and security/audit result or skipped reason. |
| Security/data | No new unsafe data exposure, privileged client write, or policy bypass. |
| Verification | Narrow proof captured in final response or task note. |
| Wiki | `.planning/llm-wiki/**` updated only when durable source-map understanding changes. |
| Git hygiene | Dirty worktrees preserved; only explicit owned paths staged. |

## 4. Verification Strategy

Use the narrowest command that proves the changed surface.

- Docs: readback plus targeted `rg` for stale references.
- Agent governance template/docs: run `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/verify-agent-governance.ps1` when this script exists.
- Source module: owning test or targeted type/check command.
- UI: desktop/mobile proof and interaction checks where visible.
- Shared runtime/build config: broader test/build only when the working tree is stable enough or the user asks.
- Security/data/migration: tests plus policy/schema/review checks from `docs/DOMAIN_GATES.md`.

Trust verification signals carefully. Whole-command "green" comes from the command exit code, not a filtered output snippet. Never accept a delegate self-report without local verification.

## 5. Edit And Git Discipline

- Search before editing; inspect local patterns.
- Keep replacements surgical.
- Use structured parsers/APIs when available.
- Do not append with shell heredocs.
- Run `git status --short` before staging.
- Stage explicit paths only; never `git add .` or `git add -A`.
- Never use blind restore/reset commands.
- If another agent changed a file after your last read, inspect the diff before editing.

## 6. Complexity And File Size

Split files when a second concern changes ownership, read timing, verification, lifecycle, search visibility, or edit safety. Do not split merely to satisfy taste. Avoid creating oversized hot files that every agent must read.

## 7. Artifacts, Wiki, And Friction

- Generated proof belongs in ignored artifacts or task notes.
- The wiki is advisory source discovery.
- Durable decisions belong in governing docs.
- Repeated rule/tool friction belongs in `.planning/friction/`.
- Close friction entries only after the rule/tool change is verified, or mark them declined with rationale.
