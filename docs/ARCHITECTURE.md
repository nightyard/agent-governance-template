# Architecture

Last verified: [YYYY-MM-DD]

Router for architecture authority. Keep this file compact; move detailed topic docs under `docs/architecture/` as the project grows.

## Principles

- Prefer existing patterns over new abstractions.
- Keep ownership boundaries explicit.
- Avoid privileged client-side writes; server-owned state changes go through backend/API boundaries.
- Shared fixes belong at the shared source when the task owns that surface.
- Generated or external plans must be mapped to current files, symbols, tests, and rollback before execution.

## Source Map

| Topic | Source |
|---|---|
| Module ownership | [fill in] |
| Routing | [fill in] |
| Data model | [fill in] |
| API boundaries | [fill in] |
| Security/data boundaries | `docs/DOMAIN_GATES.md` |

## Local Pattern Checklist

Before editing architecture-sensitive code:

- Find nearest working example.
- Check imports, exports, tests, and route/module boundaries.
- Confirm the change does not bypass shared validation or policy.
- Run targeted verification for the touched boundary.
