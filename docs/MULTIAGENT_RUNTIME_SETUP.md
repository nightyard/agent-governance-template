# Multiagent Runtime Setup

Last verified: [YYYY-MM-DD]

The kit installs a generic coordination skill, not a ready-made broker runtime. CLI agents, browser agents, broker scripts, dev-server helpers, and provider sign-in are project-owned setup.

## Runtime Truth

- `clearroute-multiagent` works immediately as a decision and packet discipline.
- CLI/browser delegation is not usable until the project selects agents, verifies sign-in/readiness, and wires broker/adapters.
- The included helper scripts are Windows-first PowerShell.
- On macOS or Linux, port broker/process/browser/dev-server runtime scripts before declaring multiagent delegation usable.

Porting includes:

- process launch, detach, wait, timeout, and status handling;
- lock files and concurrent job state;
- path resolution, quoting, and shell commands;
- browser automation setup and visible sign-in checks;
- dev-server start/status/stop helpers;
- any project-owned CLI/browser broker commands.

## Agent Selection

Ask the user which runtimes they want before setup:

- CLI agents: Codex CLI, Claude CLI, Gemini CLI, or a custom local CLI.
- Browser agents: ChatGPT, Gemini, NotebookLM, or a custom web agent.
- Broker mode: no broker, simple project scripts, or a project-owned broker.

Do not copy private broker scripts, credentials, browser profiles, CLI auth caches, cookies, keychains, token files, or machine-specific cache paths from another workstation.

## Readiness Workflow

1. Copy `.agents/templates/MULTIAGENT_RUNTIME_SETTINGS.example.json` to `.agents/runtime/MULTIAGENT_RUNTIME_SETTINGS.json`.
2. Enable only the CLI/browser agents the user selected.
3. For each CLI agent, set `command`, `versionArgs`, and, when the provider has one, a non-secret `statusArgs` command.
4. Run:

   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\check-agent-runtimes.ps1 -TargetRoot "."
   ```

5. If a selected CLI is missing, ask the user whether to install it or deselect it.
6. If a status command fails, ask the user to run the provider's interactive login flow, then rerun the readiness script.
7. For browser agents, use the configured browser automation tool to open the provider URL and inspect only visible UI state.
8. If a login page is visible, ask the user to sign in interactively, then re-check visible app state.
9. Record accepted runtime choices in project-owned docs or settings.
10. Build project-owned broker scripts using `docs/MULTIAGENT_BROKER_BUILD_GUIDE.md`.
11. Only then wire and test broker commands.

## Browser Sign-In Rule

Test before asking the user to sign in. The test is a visible app-state check, not a cache inspection.

Allowed:

- open provider URL in the configured browser automation tool;
- inspect page title, visible login button, visible account/app UI, or a provider-safe status page;
- ask the user to sign in interactively when the visible state shows they are signed out.

Forbidden:

- reading browser profile folders;
- copying cookies, local storage, or session databases;
- exporting keychain or credential manager entries;
- attaching screenshots that expose private account/customer data.

## Broker Readiness Gate

Before the multiagent skill can use CLI/browser agents, the project must have:

- selected enabled agents in `.agents/runtime/MULTIAGENT_RUNTIME_SETTINGS.json`;
- a readiness report from `scripts/check-agent-runtimes.ps1`;
- visible browser sign-in checks for enabled browser agents;
- project-owned broker/adapters with documented commands;
- scaffolded or custom broker scripts tested through `docs/MULTIAGENT_BROKER_BUILD_GUIDE.md`;
- platform-specific proof on the current OS;
- local verification that delegate output remains advisory and source-grounded.
