---
description: Practical loop for broad, concurrent, repetitive, or review-heavy agent work.
---

# Multi-Agent Loop

Use this workflow when one goal involves multiple agents, long-running slices, shared runtimes, or overlapping write scopes. Read `.agents/skills/multiagent-coordination/SKILL.md` first for routing.

## 1. Classify

- Stay local for tiny, sensitive, tightly coupled, or unclear tasks.
- Use orchestration for broad, repetitive, isolated, review-heavy, or explicitly multi-model work where delegation saves time after verification.
- Do not delegate if the write scope is ambiguous, secrets/private data would be exposed, or local verification is impossible.

## 2. Preflight

- Read only governing sections needed for the task.
- Declare risk tier, owned files, allowed actions, forbidden actions, and proof requirement.
- Claim or communicate write scopes if multiple agents may touch nearby files. Use `scripts/claim-scope.ps1` and `scripts/release-scope.ps1` when this kit is installed; otherwise use the local IDE/team convention.
- For long-running slices, record a compact checkpoint with `scripts/record-checkpoint.ps1` or an equivalent task note.
- Create a task packet when another agent needs context.

## 3. Delegate

Every delegate packet should include:

- objective and task type;
- risk tier from `docs/DOMAIN_GATES.md`;
- named source anchors or attached excerpts;
- owned read/write scope;
- whether edits are allowed;
- expected output schema or answer shape;
- stop condition and response budget;
- task-scoped skill/workflow allowlist;
- instruction that output is advisory until locally verified.

For browser or code-blind agents, include source excerpts and artifacts directly; do not rely on local file paths they cannot access.

## 4. Verify And Close

- Verify useful delegate claims with direct local reads and tests.
- Record accepted and rejected findings when delegates materially influenced the result.
- Run the narrowest meaningful verification for the touched surface.
- Release or communicate write scopes.
- Handoff includes changed files, verification commands, evidence paths, delegate sessions if any, unrelated blockers, and open friction entries.
