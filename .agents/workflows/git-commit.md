---
description: Explicit-path Git commit workflow.
---

# Git Commit

Use only when the user asks to stage, commit, push, or prepare a PR.

## Preflight

1. Run `git status --short`.
2. Inspect diffs for every file you plan to stage.
3. Confirm unrelated dirty files remain untouched.
4. Run or cite the relevant verification for your changed files.

## Stage

Stage explicit paths only:

```powershell
git add -- path/to/file1 path/to/file2
```

Never use `git add .` or `git add -A`.

## Commit

Use a concise message that names the change and scope. Do not include generated artifacts, logs, screenshots, temporary scripts, or private task notes unless the user explicitly asked.

## Push

Before pushing, fetch and confirm the branch is not behind its upstream. Never force-push unless the user explicitly requested and understands the impact.
