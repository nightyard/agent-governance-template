# Domain Gates

Last verified: [YYYY-MM-DD]

Replace these placeholders with the project's real high-risk rules. Until then, agents must treat production, data, security, compliance, billing, migrations, and external effects as gated.

## Risk Tiers

| Tier | Meaning | Default action |
|---|---|---|
| `routine` | Local, reversible, low-risk change | Proceed with normal verification |
| `shared` | Shared module, route, workflow, build, or architecture seam | Source audit and targeted verification |
| `data_write` | Writes customer/business data or changes persistence | Stop unless approved; require tests and rollback |
| `security` | Auth, secrets, permissions, encryption, network boundary | Stop unless approved; require review/proof |
| `billing` | Payments, invoices, subscriptions, entitlements | Stop unless approved; require owner signoff |
| `production` | Deploys, production jobs, external notifications | Stop unless approved for this task |
| `dependency` | New production package or external service | Ask first; verify provenance and audit |
| `git_history` | Force push, reset, rebase shared branch, history rewrite | Ask first; default no |

## Classification Template

Before editing gated work, declare:

- Surface:
- Risk tier:
- Commercial/user impact:
- Allowed actions:
- Forbidden actions:
- Owner-approved source:
- Required verification:
- Rollback path:

## Default Forbidden Without Approval

- Production deploys or jobs.
- Destructive migrations or data deletion.
- Customer/user notification.
- Credential, token, or secret rotation.
- Payment, billing, or entitlement changes.
- Force push, history rewrite, or branch reset.
- Sending private data to external tools.
- Installing production dependencies.

## Domain-Specific Rules

Add project-specific rules here, for example regulated copy rules, data retention, industry compliance, vendor approval, model usage, release criteria, or customer-facing language.
