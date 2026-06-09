#!/usr/bin/env node
import { spawnSync } from "node:child_process";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const scriptDir = path.dirname(fileURLToPath(import.meta.url));
const root = findRepoRoot(path.resolve(scriptDir, ".."));
const args = parseArgs(process.argv.slice(2));
const command = args._[0] || "status";
const settings = readSettings(root);

if (command === "status") {
  json({ ok: true, cliAgents: settings.cliAgents.map(statusForCli) });
}
else if (command === "run") {
  runOne(args);
}
else if (command === "panel") {
  runPanel(args);
}
else {
  fail(`Unknown command: ${command}`);
}

function runOne(opts) {
  const id = opts.agent;
  const packetPath = opts.packet;
  if (!id) fail("Missing --agent");
  if (!packetPath) fail("Missing --packet");
  const agent = settings.cliAgents.find((item) => item.id === id);
  if (!agent) fail(`Unknown CLI agent: ${id}`);
  const result = invokeAgent(agent, packetPath, opts["task-id"] || `cli-${id}-${Date.now()}`);
  json(result);
}

function runPanel(opts) {
  const ids = String(opts.agents || "").split(",").map((item) => item.trim()).filter(Boolean);
  if (ids.length === 0) fail("Missing --agents a,b");
  if (!opts.packet) fail("Missing --packet");
  const results = ids.map((id) => {
    const agent = settings.cliAgents.find((item) => item.id === id);
    return agent ? invokeAgent(agent, opts.packet, opts["task-id"] || `cli-panel-${Date.now()}`) : { ok: false, agent: id, error: "unknown_agent" };
  });
  json({ ok: true, results });
}

function invokeAgent(agent, packetPath, taskId) {
  if (!agent.enabled) return { ok: false, agent: agent.id, status: "disabled" };
  if (!commandPresent(agent.command)) return { ok: false, agent: agent.id, status: "command_missing", command: agent.command };
  if (!agent.delegateArgsTemplate || agent.delegateArgsTemplate.length === 0) {
    return { ok: false, agent: agent.id, status: "delegate_args_not_configured", message: "Set delegateArgsTemplate in .agents/runtime/MULTIAGENT_RUNTIME_SETTINGS.json." };
  }

  const absolutePacket = path.resolve(root, packetPath);
  const packetText = fs.readFileSync(absolutePacket, "utf8");
  const renderedArgs = agent.delegateArgsTemplate.map((item) =>
    String(item)
      .replaceAll("{{packetPath}}", absolutePacket)
      .replaceAll("{{packetText}}", packetText)
      .replaceAll("{{taskId}}", taskId)
  );
  const startedAt = new Date().toISOString();
  const child = spawnSync(agent.command, renderedArgs, { cwd: root, encoding: "utf8", timeout: Number(agent.timeoutMs || 900000), shell: false });
  const output = redact(`${child.stdout || ""}\n${child.stderr || ""}`.trim());
  const outDir = path.join(root, ".planning", "orchestrator-bundles", taskId);
  fs.mkdirSync(outDir, { recursive: true });
  const artifact = path.join(outDir, `${agent.id}.json`);
  const record = {
    ok: child.status === 0,
    agent: agent.id,
    startedAt,
    completedAt: new Date().toISOString(),
    exitCode: child.status,
    signal: child.signal,
    output,
    packet: absolutePacket
  };
  fs.writeFileSync(artifact, JSON.stringify(record, null, 2), "utf8");
  return { ...record, artifact };
}

function statusForCli(agent) {
  return { id: agent.id, enabled: !!agent.enabled, command: agent.command, commandPresent: commandPresent(agent.command), delegateArgsConfigured: !!(agent.delegateArgsTemplate && agent.delegateArgsTemplate.length) };
}

function readSettings(root) {
  const target = path.join(root, ".agents", "runtime", "MULTIAGENT_RUNTIME_SETTINGS.json");
  const fallback = path.join(root, ".agents", "templates", "MULTIAGENT_RUNTIME_SETTINGS.example.json");
  const file = fs.existsSync(target) ? target : fallback;
  if (!fs.existsSync(file)) fail("Missing multiagent runtime settings.");
  return JSON.parse(fs.readFileSync(file, "utf8"));
}

function commandPresent(commandName) {
  if (!commandName || /^\[/.test(commandName)) return false;
  const probe = spawnSync(process.platform === "win32" ? "where" : "command", process.platform === "win32" ? [commandName] : ["-v", commandName], { encoding: "utf8", shell: process.platform !== "win32" });
  return probe.status === 0;
}

function parseArgs(argv) {
  const out = { _: [] };
  for (let i = 0; i < argv.length; i++) {
    const item = argv[i];
    if (!item.startsWith("--")) {
      out._.push(item);
      continue;
    }
    const key = item.slice(2);
    out[key] = argv[i + 1] && !argv[i + 1].startsWith("--") ? argv[++i] : true;
  }
  return out;
}

function findRepoRoot(start) {
  let dir = path.resolve(start);
  while (dir !== path.dirname(dir)) {
    if (fs.existsSync(path.join(dir, ".git"))) return dir;
    dir = path.dirname(dir);
  }
  return path.resolve(start);
}

function redact(text) {
  return String(text).replace(/\b(api[_-]?key|access[_-]?token|refresh[_-]?token|session[_-]?cookie|client[_-]?secret|password)\s*[:=]\s*['"]?[^'"\s]+['"]?/gi, "$1=[REDACTED]");
}

function json(value) {
  console.log(JSON.stringify(value, null, 2));
}

function fail(message) {
  json({ ok: false, error: message });
  process.exit(1);
}
