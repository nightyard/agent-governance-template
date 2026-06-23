---
name: clearroute-multiagent
description: Generic multi-agent routing and packet discipline for broad, parallel, repetitive, review-heavy, or second-opinion work. Codex or the primary IDE agent remains final editor and verifier.
---

# ClearRoute Multiagent

Use this when delegation is cheaper than loading and reasoning through everything inline. Delegates are advisory until checked against local sources.

## Non-Negotiable Invariants

- Do not expose secrets, credentials, private customer data, or production material to external agents.
- Do not include local CLI profiles, browser profiles, auth caches, session stores, cookies, token files, keychains, or machine-specific cache paths in this skill, its references, packets, artifacts, screenshots, or delegate prompts.
- Build source-rich packets for workspace-tied work, especially when local state is dirty or uncommitted.
- Prefer read-only delegation unless the user explicitly wants a delegate to edit and the write scope is bounded.
- For local multi-agent editing, claim/release write scopes with the installed helper scripts or the local team's equivalent convention.
- Browser or connectorless agents must receive source excerpts, screenshots, logs, or artifacts directly; do not rely on local paths they cannot open.
- For broad or risky work, include one adversarial or completeness-focused review pass.
- Count only completed, source-grounded delegate answers. Provider errors, empty captures, capacity failures, and wrapper non-answers are not model votes.
- The primary agent verifies useful claims locally before editing or reporting them as done.

## Quick Decision

Delegate when any of: 15+ files, 3+ silos, repeated slices, fanout, compare-approaches, second-model opinion, large review/audit, visual/browser critique, or long-running work.

Stay local when the task is tiny, sensitive, one-file, tightly coupled, cheaper to verify locally, or blocked by missing permission to share context.

## Runtime Status

This skill is a coordination layer. It does not bundle a CLI broker, browser broker, dev-server broker, provider accounts, browser automation profile, or auth setup.

Before using CLI or browser delegates:

1. Follow `.agents/workflows/multiagent-runtime-setup.md`.
2. Select the CLI/browser agents the user wants.
3. Run `scripts/check-agent-runtimes.ps1` before asking the user to sign in.
4. Ask for interactive sign-in only when a selected CLI status check fails or a browser visible-state check shows a login screen.
5. Build project-owned brokers with `.agents/workflows/multiagent-broker-build.md`.
6. Verify a read-only packet round trip.

The included helper scripts are Windows-first PowerShell. On macOS or Linux, port broker, CLI, browser, and dev-server helper runtime scripts before marking multiagent delegation usable.

## Standard Workflow

1. Decide if delegation beats verification overhead.
2. Create or identify a packet with objective, source anchors, risk tier, allowed actions, forbidden actions, expected output, stop condition, and verification requirement.
3. Send the packet through the available local mechanism: Codex subagent, CLI delegate, browser agent, or manual peer review.
4. Verify source-grounded claims locally before editing.
5. Record accepted/rejected delegate findings in the final response or task note when material.

## Reference Map

- `references/routing.md` - channel choice and fallback rules.
- `references/evidence-packets.md` - packet fields and prompt shape.
