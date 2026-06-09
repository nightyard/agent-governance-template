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
  json({ ok: true, browserAgents: settings.browserAgents.map((agent) => ({ id: agent.id, enabled: !!agent.enabled, url: agent.url, launchCommandConfigured: !!(agent.launchCommandTemplate && agent.launchCommandTemplate.length) })) });
}
else if (command === "run") {
  const provider = args.provider;
  const packet = args.packet;
  if (!provider) fail("Missing --provider");
  if (!packet) fail("Missing --packet");
  const agent = settings.browserAgents.find((item) => item.id === provider);
  if (!agent) fail(`Unknown browser agent: ${provider}`);
  json(runBrowser(agent, packet, args["task-id"] || `browser-${provider}-${Date.now()}`));
}
else {
  fail(`Unknown command: ${command}`);
}

function runBrowser(agent, packetPath, taskId) {
  if (!agent.enabled) return { ok: false, provider: agent.id, status: "disabled" };
  if (!agent.launchCommandTemplate || agent.launchCommandTemplate.length === 0) {
    return {
      ok: false,
      provider: agent.id,
      status: "browser_broker_not_configured",
      message: "Configure launchCommandTemplate for this provider, or use a local browser automation plugin. Read docs/MULTIAGENT_RUNTIME_SETUP.md."
    };
  }
  const absolutePacket = path.resolve(root, packetPath);
  const packetText = fs.readFileSync(absolutePacket, "utf8");
  const rendered = agent.launchCommandTemplate.map((item) =>
    String(item)
      .replaceAll("{{url}}", agent.url)
      .replaceAll("{{packetPath}}", absolutePacket)
      .replaceAll("{{packetText}}", packetText)
      .replaceAll("{{taskId}}", taskId)
  );
  const [cmd, ...cmdArgs] = rendered;
  const child = spawnSync(cmd, cmdArgs, { cwd: root, encoding: "utf8", timeout: Number(agent.timeoutMs || 900000), shell: false });
  const output = redact(`${child.stdout || ""}\n${child.stderr || ""}`.trim());
  const outDir = path.join(root, ".planning", "orchestrator-bundles", taskId);
  fs.mkdirSync(outDir, { recursive: true });
  const artifact = path.join(outDir, `${agent.id}.json`);
  const record = { ok: child.status === 0, provider: agent.id, exitCode: child.status, signal: child.signal, output, packet: absolutePacket };
  fs.writeFileSync(artifact, JSON.stringify(record, null, 2), "utf8");
  return { ...record, artifact };
}

function readSettings(root) {
  const target = path.join(root, ".agents", "runtime", "MULTIAGENT_RUNTIME_SETTINGS.json");
  const fallback = path.join(root, ".agents", "templates", "MULTIAGENT_RUNTIME_SETTINGS.example.json");
  const file = fs.existsSync(target) ? target : fallback;
  if (!fs.existsSync(file)) fail("Missing multiagent runtime settings.");
  return JSON.parse(fs.readFileSync(file, "utf8"));
}

function parseArgs(argv) {
  const out = { _: [] };
  for (let i = 0; i < argv.length; i++) {
    const item = argv[i];
    if (!item.startsWith("--")) out._.push(item);
    else {
      const key = item.slice(2);
      out[key] = argv[i + 1] && !argv[i + 1].startsWith("--") ? argv[++i] : true;
    }
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
