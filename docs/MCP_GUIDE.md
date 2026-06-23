# MCP And Tooling Guide

Last verified: [YYYY-MM-DD]

Use local repo evidence first. MCP servers and external tools are task-specific aids, not authority.

## Rules

- Do not send secrets, credentials, private customer data, or production material to external tools.
- Do not connect, export, attach, or summarize local auth caches, browser profiles, CLI profile folders, cookies, token files, keychains, or session stores.
- Prefer official docs or primary sources for facts that may have changed.
- Keep the active tool surface proportionate to the task.
- Record tool limitations or failures when they affect confidence.
- Tool names may differ by agent environment; do not hard-code assumptions in governance.

## Common Tool Classes

| Need | Preferred source |
|---|---|
| Repo search | `rg`, language server, local files |
| Current public/API facts | Official docs or primary source |
| Browser proof | Local browser automation or screenshots |
| Spreadsheet/doc/slides | Installed connector or local parser |
| Multi-agent review | `.agents/skills/clearroute-multiagent/SKILL.md` |
