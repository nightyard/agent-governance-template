# Evidence Packets

Packets make delegation reliable by replacing vague prompts with bounded source context.

## Required Fields

- objective;
- task id or slug;
- workspace/repo name;
- branch and dirty-state note;
- risk tier from `docs/DOMAIN_GATES.md`;
- source anchors and excerpts;
- artifacts, screenshots, logs, or diffs if relevant;
- read/write scope;
- whether edits are allowed;
- allowed actions and forbidden actions;
- expected output format;
- stop condition and response budget;
- local verification required;
- task-scoped skill or workflow allowlist.

## Never Include

- CLI or browser profile/cache directories;
- cookies, session storage, auth caches, refresh tokens, API keys, SSH keys, or keychain exports;
- machine-specific user profile paths unless they are harmless repo paths required for local verification;
- screenshots or logs that expose credentials, private account names, customer data, or production material.

## Adversarial Prompt

Use this when coverage matters:

```text
Review adversarially. Look for stale paths, missing source families, weak assumptions, unsafe scope expansion, hidden dependencies, untested claims, and verification gaps. Return blockers first, then enhancements. Label hypotheses clearly and include local verification steps.
```

## Grounding Rules

- Local packet beats browser context for dirty or uncommitted files.
- Source excerpts beat path-only references for agents without filesystem access.
- Web search may clarify current public facts, but must not override local repo authority without an explicit adoption step.
- Do not include secrets, credentials, customer data, or private production material.
