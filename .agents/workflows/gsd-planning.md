---
description: GSD-inspired planning loop for agentic IDE work. Map first, plan second, execute in bounded slices.
---

# GSD Planning

Use this when a goal is broad, ambiguous, multi-step, or likely to sprawl. The point is not ceremony; it is preventing agents from acting on stale maps.

## 1. Map Before Plan

- Restate the objective in one paragraph.
- Identify owner-approved constraints, hard stops, and non-goals.
- Search for existing code/docs/workflows before inventing new structure.
- Build a compact source audit: files, symbols, routes, commands, tests, external facts, open blockers, and assumptions.
- Mark facts as verified, inferred, or unknown.

## 2. Bound The Work

- Choose the smallest useful slice that produces verifiable value.
- Declare read/write scope and files you expect to touch.
- Classify risk using `docs/DOMAIN_GATES.md`.
- Decide whether the task needs a formal spec under `.planning/<task-slug>_SPEC.md`.
- For external packages or templates, verify provenance and map them to repo authority before use.

## 3. Plan-Checker Loop

Before editing, challenge the plan:

- What source did this depend on?
- What file or symbol might contradict it?
- What could break outside the intended scope?
- What must be true for the verification to mean anything?
- What rollback path exists if the change is wrong?

Use a delegate or subagent for this only when the scope justifies it. Delegate output remains advisory.

## 4. Execute In Slices

- Implement one coherent slice at a time.
- Keep edits surgical and local to the declared scope.
- Re-read changed files before a second pass if another agent or user may have edited them.
- Stop if new production/data/security/compliance risk appears.

## 5. Prove And Handoff

- Run the narrowest verification command that proves the changed surface.
- Record what passed, what was not run, and any unrelated failures.
- Update durable docs only if durable project understanding changed.
- Log governance/tooling friction under `.planning/friction/` if a rule was stale, contradictory, missing, or impossible.
