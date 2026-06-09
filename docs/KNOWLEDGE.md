# Knowledge And Current Facts

Last verified: [YYYY-MM-DD]

Router for current facts, constants, vendor references, prices, thresholds, policies, and external sources. Official/current sources win over stale local docs.

## Source Cascade

1. Official or owner-approved external source.
2. Canonical local constant/config/source file.
3. Derived docs.
4. UI/copy consumers.
5. Tests/proof.

## Tracked Sources

| Topic | Authoritative source | Local source | Verification cadence |
|---|---|---|---|
| [topic] | [URL or owner doc] | [path] | [cadence] |

## Rules

- Do not spread volatile values across source files.
- Verify facts that can change before editing.
- Add a tracked source row before introducing a new recurring external fact.
- Use `.agents/workflows/cascade-fix.md` for narrow corrections.
