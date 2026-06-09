# Context Performance Review

Last verified: [YYYY-MM-DD]

## Operating Rule

Performance wins by retrieval design, not by hiding safety rules. Keep the hot agent entry path compact and visible:

- `AGENTS.md`
- `CLAUDE.md`
- `GEMINI.md`
- `.agents/rules/rules.md`
- `.agents/workflows/agent-onboarding.md`
- `.planning/ACTIVE_CONTEXT_STATE.json`
- `.planning/ACTIVE_CONTEXT.md`
- `.planning/llm-wiki/index.md`

Do not put raw logs, stack traces, generated packets, screenshots, provider payloads, or long command output in always-read files.

## Agent Quick Use

- Start from `AGENTS.md`; cold starts also read `.agents/workflows/agent-onboarding.md`.
- Use `.planning/ACTIVE_CONTEXT_STATE.json` as the compact broad-work map.
- Use `.planning/llm-wiki/index.md` for source discovery only.
- Use `.planning/friction/README.md` for governance/tooling friction.
- Use default search for normal work; use deep/no-ignore search only for explicit archive or generated-artifact review.

## Budgets

Budgets and caps are defined in `.agents/startup-profiles.json`.

Suggested defaults:

- `AGENTS.md`: target under 1100 words.
- `.agents/rules/rules.md`: target under 300 words.
- `.agents/workflows/agent-onboarding.md`: target under 650 words.
- `.planning/ACTIVE_CONTEXT.md`: warn above 8 KB, compact before 12 KB.
- Aggregate always-read startup files: target under 3000 words.

## Search Visibility Tiers

- Hot entrypoints: always visible and compact.
- Warm maps: wiki pages, workflow indexes, authority map.
- Cold history: old specs, logs, proof, generated packets, screenshots, archives.
- Generated/cache: build output, coverage, browser reports, temporary delegate handoffs.

Only cold history and generated/cache material should be hidden from default search. Hot memory and governing docs must remain visible.
