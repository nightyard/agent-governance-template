---
description: Narrow authoritative-source correction workflow.
---

# Cascade Fix

Use this for a single known fact, config, copy, price, threshold, policy, or vendor value correction.

## Steps

1. Identify the authoritative source in `docs/KNOWLEDGE.md` or the owner-approved source list.
2. Verify the current value from that source if it can change.
3. Find the canonical local constant/config/doc entry before editing app code.
4. Update in cascade order: source reference, constant/config, derived docs, tests, then UI/copy consumers.
5. Search for stale duplicates.
6. Run the narrowest verification: unit tests for calculators/parsers, snapshot/readback for docs, or targeted type/test checks for consumers.

Do not spread hardcoded volatile values across source files. If there is no cascade yet, propose one or create the smallest local source-of-truth file consistent with the project pattern.
