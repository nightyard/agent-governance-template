#!/usr/bin/env node
import { spawnSync } from "node:child_process";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const scriptDir = path.dirname(fileURLToPath(import.meta.url));
const root = findRepoRoot(path.resolve(scriptDir, ".."));
const args = process.argv.slice(2);
const command = args[0] || "status";
const settings = readSettings(root);
const dev = settings.devServer || {};

if (command === "status") {
  const url = dev.url || "";
  const reachable = url ? checkUrl(url) : false;
  console.log(JSON.stringify({ ok: true, configured: !!dev.command, url, reachable }, null, 2));
}
else if (command === "ensure") {
  if (!dev.command) {
    console.log(JSON.stringify({ ok: false, status: "dev_server_not_configured", message: "Set devServer.command in .agents/runtime/MULTIAGENT_RUNTIME_SETTINGS.json." }, null, 2));
    process.exit(1);
  }
  const parts = Array.isArray(dev.command) ? dev.command : String(dev.command).split(" ");
  const child = spawnSync(parts[0], parts.slice(1), { cwd: root, encoding: "utf8", timeout: Number(dev.timeoutMs || 30000), shell: process.platform === "win32" });
  console.log(JSON.stringify({ ok: child.status === 0, exitCode: child.status, outputPreview: `${child.stdout || ""}\n${child.stderr || ""}`.trim().slice(0, 500) }, null, 2));
}
else {
  console.log(JSON.stringify({ ok: false, error: `Unknown command: ${command}` }, null, 2));
  process.exit(1);
}

function readSettings(root) {
  const target = path.join(root, ".agents", "runtime", "MULTIAGENT_RUNTIME_SETTINGS.json");
  const fallback = path.join(root, ".agents", "templates", "MULTIAGENT_RUNTIME_SETTINGS.example.json");
  const file = fs.existsSync(target) ? target : fallback;
  return fs.existsSync(file) ? JSON.parse(fs.readFileSync(file, "utf8")) : {};
}

function checkUrl(url) {
  try {
    const result = spawnSync("node", ["-e", `fetch(${JSON.stringify(url)}).then(r=>process.exit(r.ok?0:1)).catch(()=>process.exit(1))`], { encoding: "utf8", timeout: 5000 });
    return result.status === 0;
  } catch {
    return false;
  }
}

function findRepoRoot(start) {
  let dir = path.resolve(start);
  while (dir !== path.dirname(dir)) {
    if (fs.existsSync(path.join(dir, ".git"))) return dir;
    dir = path.dirname(dir);
  }
  return path.resolve(start);
}
