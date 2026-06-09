# Routing

Use the lightest channel that can produce a verifiable answer.

| Task shape | Route |
|---|---|
| Tiny, sensitive, one-file, or tightly coupled | Stay local |
| Broad read-heavy sweep | Read-only CLI/subagent review |
| Scoped implementation draft | Delegate only with explicit write scope; primary verifies diffs |
| Architecture/security/design critique | Second model or reviewer, adversarial prompt |
| Browser/render/localhost proof | Browser automation or visual reviewer with screenshots/logs |
| Public/current research | Web-capable agent, with citations and separation from local facts |

Delegate output is never authority by itself. Local repo state and governing docs win over external suggestions.

CLI/browser routes require completed runtime setup: selected agents, readiness report, sign-in checks, and project-owned broker/adapters. On macOS or Linux, port Windows-first runtime helpers before using those routes.

Do not route credential, auth-cache, browser-profile, cookie, keychain, token, or private-production-data inspection to external delegates. Handle that work locally, redact aggressively, and report only non-sensitive conclusions.
