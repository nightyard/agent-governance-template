# Agent Surfaces

Last verified: [YYYY-MM-DD]

This map keeps different agentic IDEs pointed at the same authority. It is not a second rules file.

| Surface | Entrypoint | Notes |
|---|---|---|
| Codex / OpenAI coding agent | `AGENTS.md` | Canonical source for hard stops, profiles, hierarchy, and conflict order. |
| Claude Code / Claude Desktop | `CLAUDE.md` -> `AGENTS.md` | Thin dispatcher only. Do not duplicate rules in Claude-specific files. |
| Gemini / browser agent / external coding tools | `GEMINI.md` -> `AGENTS.md` | Thin dispatcher only. Give code-blind browser agents source excerpts or packets. |
| Injected rules systems | `.agents/rules/rules.md` -> `AGENTS.md` | Compact hot-path dispatcher. |
| Project skills | `.agents/skills/INDEX.md` | Skills are routing aids below `AGENTS.md` and `docs/`. |
| Project workflows | `.agents/WORKFLOWS_INDEX.md` | Workflows are repeatable procedures below governing docs. |
| MCP / connectors | `docs/MCP_GUIDE.md` | Tool availability differs by environment; local evidence wins. |
| Active planning state | `.planning/ACTIVE_CONTEXT_STATE.json` | Read only for broad/current-state posture. |
| LLM wiki | `.planning/llm-wiki/index.md` | Source discovery only; never authority. |

When adding another agent surface, add a thin dispatcher that points back to `AGENTS.md` and update this map.
