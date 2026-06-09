# [PROJECT_NAME] Gemini Entrypoint

`AGENTS.md` is the source of truth. This file only keeps Gemini or browser-agent tooling pointed at the canonical entrypoint.

Read `AGENTS.md`; if `.agents/rules/rules.md` is injected, treat it as a compact dispatcher back to `AGENTS.md`. For machine routing, parse `.agents/AGENT_BOOTSTRAP.json`. For MCP or workstation setup tasks, also read `docs/MCP_GUIDE.md`.

Do not duplicate product, security, or workflow rules here. Update `AGENTS.md`, `.agents/rules/rules.md`, or the governing docs instead.
