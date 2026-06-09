#!/usr/bin/env node
import { spawnSync } from "node:child_process";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const scriptDir = path.dirname(fileURLToPath(import.meta.url));
const root = findRepoRoot(path.resolve(scriptDir, ".."));
const surface = process.argv[2] || "status";
const rest = process.argv.slice(3);
const scripts = {
  packet: "build-multiagent-evidence-packet.mjs",
  cli: "cli-delegate-broker.mjs",
  browser: "browser-agent-broker.mjs",
  dev: "dev-server-broker.mjs"
};

if (surface === "status") {
  const statuses = {};
  for (const key of Object.keys(scripts)) statuses[key] = fs.existsSync(path.join(root, "scripts", scripts[key]));
  console.log(JSON.stringify({ ok: true, brokerScripts: statuses }, null, 2));
  process.exit(0);
}

if (!scripts[surface]) {
  console.log(JSON.stringify({ ok: false, error: `Unknown surface: ${surface}`, surfaces: ["status", ...Object.keys(scripts)] }, null, 2));
  process.exit(1);
}

const target = path.join(root, "scripts", scripts[surface]);
if (!fs.existsSync(target)) {
  console.log(JSON.stringify({ ok: false, error: `Missing broker script: ${target}` }, null, 2));
  process.exit(1);
}

const child = spawnSync("node", [target, ...rest], { cwd: root, stdio: "inherit", shell: false });
process.exit(child.status ?? 1);

function findRepoRoot(start) {
  let dir = path.resolve(start);
  while (dir !== path.dirname(dir)) {
    if (fs.existsSync(path.join(dir, ".git"))) return dir;
    dir = path.dirname(dir);
  }
  return path.resolve(start);
}
