# Workflow Index

Last verified: [YYYY-MM-DD]

Discovery map for canonical project workflows under `.agents/workflows/`. Use this only when choosing a repeatable process; it is not an always-read startup file.

| Workflow | Use when | Path |
|---|---|---|
| `agent-onboarding` | Cold-starting or choosing a bounded read profile for unfamiliar work | `.agents/workflows/agent-onboarding.md` |
| `gsd-planning` | Turning a broad goal into a source-audited plan, safe MVP, or task spec | `.agents/workflows/gsd-planning.md` |
| `multi-agent-loop` | Running a bounded multi-agent review, implementation, or convergence loop | `.agents/workflows/multi-agent-loop.md` |
| `cascade-fix` | Making a narrow fact/config/copy correction through authoritative sources and constants | `.agents/workflows/cascade-fix.md` |
| `git-commit` | Preparing an explicit-path commit with verification and no blanket staging | `.agents/workflows/git-commit.md` |

Helper scripts:

- `scripts/claim-scope.ps1` records a portable write-scope claim in `.planning/write-locks.json`.
- `scripts/release-scope.ps1` releases a write-scope claim.
- `scripts/record-checkpoint.ps1` appends compact long-running work checkpoints to `.planning/agent-checkpoints.md`.
- `scripts/new-agent-spec.ps1` creates `.planning/<slug>_SPEC.md` from the template.
- `scripts/new-agent-friction.ps1` creates `.planning/friction/YYYY-MM-DD-<slug>.md` from the template.
- `scripts/land-agent-friction.ps1` marks a friction entry `landed` or `declined` after manual verification.
