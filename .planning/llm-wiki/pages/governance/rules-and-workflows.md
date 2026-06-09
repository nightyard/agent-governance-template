# Rules And Workflows

Generated synthesis, non-authoritative.

## Governing Shape

`AGENTS.md` is the repo entrypoint. `.agents/rules/rules.md`, `CLAUDE.md`, and `GEMINI.md` are compact dispatchers back to it.

The operating model classifies task/spec needs. The workflow protocol owns Definition of Done, verification, edit discipline, artifact policy, and Git hygiene. `docs/DOMAIN_GATES.md` owns project-specific high-risk gates.

Agents choose the lightest path first: direct for small known work, cold start for unfamiliar areas, broad/current-state only when live posture matters, GSD planning for ambiguous goals, and multi-agent coordination for justified delegation.

Delegation is a routing mode, not a startup profile. Send bounded source-rich packets, keep delegates read-only by default, and verify claims locally before editing.

## Workflow Map

- Cold start: `.agents/workflows/agent-onboarding.md`
- Planning: `.agents/workflows/gsd-planning.md`
- Delegation: `.agents/skills/multiagent-coordination/SKILL.md`
- Narrow source correction: `.agents/workflows/cascade-fix.md`
- Post-work Git: `.agents/workflows/git-commit.md`
- Friction: `.planning/friction/README.md`

## Sources

- `AGENTS.md`
- `.agents/rules/rules.md`
- `docs/AGENT_OPERATING_MODEL.md`
- `docs/WORKFLOW_PROTOCOL.md`
- `docs/DOMAIN_GATES.md`
- `.agents/WORKFLOWS_INDEX.md`
- `.agents/skills/multiagent-coordination/SKILL.md`
