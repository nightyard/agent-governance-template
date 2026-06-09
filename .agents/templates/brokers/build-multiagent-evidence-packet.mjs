#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import { execFileSync } from "node:child_process";
import { fileURLToPath } from "node:url";

const args = parseArgs(process.argv.slice(2));
const scriptDir = path.dirname(fileURLToPath(import.meta.url));
const root = findRepoRoot(path.resolve(scriptDir, ".."));
const taskId = args["task-id"] || slug(args.objective || "multiagent-task");
const outDir = path.resolve(root, args["out-dir"] || path.join("agent-handoffs", taskId));
const sourceArgs = asArray(args.source);
const maxFiles = Number(args["max-files"] || 30);
const maxChars = Number(args["max-chars-per-file"] || 3000);

if (!args.objective) fail("Missing --objective");
fs.mkdirSync(outDir, { recursive: true });

const files = collectFiles(root, sourceArgs, maxFiles);
const excerpts = files.map((file) => ({
  path: rel(root, file),
  excerpt: safeExcerpt(file, maxChars),
}));

const packet = {
  schema_version: 1,
  task_id: taskId,
  objective: args.objective,
  created_at_utc: new Date().toISOString(),
  repo_root: root,
  branch: git(["branch", "--show-current"]) || "unknown",
  dirty_state: git(["status", "--short"]) || "",
  risk_tier: args["risk-tier"] || "unknown",
  expected_output: args["expected-output"] || "source-grounded findings with local verification steps",
  stop_condition: args["stop-condition"] || "Return concise findings only.",
  local_verification_required: true,
  excerpts,
};

const markdown = renderPacket(packet);
const packetMd = path.join(outDir, "packet.md");
const packetJson = path.join(outDir, "packet.json");
fs.writeFileSync(packetMd, markdown, "utf8");
fs.writeFileSync(packetJson, JSON.stringify(packet, null, 2), "utf8");

console.log(JSON.stringify({ ok: true, task_id: taskId, packet: packetMd, packet_json: packetJson, excerpt_count: excerpts.length }, null, 2));

function parseArgs(argv) {
  const out = {};
  for (let i = 0; i < argv.length; i++) {
    const item = argv[i];
    if (!item.startsWith("--")) continue;
    const key = item.slice(2);
    const value = argv[i + 1] && !argv[i + 1].startsWith("--") ? argv[++i] : true;
    if (out[key]) out[key] = Array.isArray(out[key]) ? [...out[key], value] : [out[key], value];
    else out[key] = value;
  }
  return out;
}

function asArray(value) {
  if (!value) return ["AGENTS.md", "docs", ".agents"];
  return Array.isArray(value) ? value : [value];
}

function findRepoRoot(start) {
  let dir = path.resolve(start);
  while (dir !== path.dirname(dir)) {
    if (fs.existsSync(path.join(dir, ".git"))) return dir;
    dir = path.dirname(dir);
  }
  return path.resolve(start);
}

function collectFiles(root, sources, limit) {
  const results = [];
  for (const source of sources) {
    const absolute = path.resolve(root, source);
    if (!fs.existsSync(absolute)) continue;
    walk(absolute, results, limit);
    if (results.length >= limit) break;
  }
  return results;
}

function walk(target, results, limit) {
  if (results.length >= limit) return;
  const stat = fs.statSync(target);
  if (stat.isDirectory()) {
    for (const entry of fs.readdirSync(target)) {
      if (skipPath(entry)) continue;
      walk(path.join(target, entry), results, limit);
      if (results.length >= limit) return;
    }
  } else if (stat.isFile() && isText(target) && !skipPath(target)) {
    results.push(target);
  }
}

function isText(file) {
  return /\.(md|mdx|txt|json|js|mjs|cjs|ts|tsx|jsx|py|ps1|yml|yaml|toml|rs|go|java|cs|rb|php|sql)$/i.test(file);
}

function skipPath(value) {
  const normal = value.replaceAll("\\", "/");
  return /(^|\/)(\.git|node_modules|dist|build|coverage|\.next|playwright-report|test-results|\.env|agent-runtime-readiness\.local\.json|workspace-discovery\.local\.json)(\/|$)/i.test(normal);
}

function safeExcerpt(file, maxChars) {
  let text = fs.readFileSync(file, "utf8");
  text = redact(text);
  return text.length > maxChars ? `${text.slice(0, maxChars)}\n...[truncated]` : text;
}

function redact(text) {
  return text
    .replace(/-----BEGIN[\s\S]+?-----END [^-]+KEY-----/g, "[REDACTED_PRIVATE_KEY]")
    .replace(/\b(api[_-]?key|access[_-]?token|refresh[_-]?token|session[_-]?cookie|client[_-]?secret|password)\s*[:=]\s*['"]?[^'"\s]+['"]?/gi, "$1=[REDACTED]");
}

function renderPacket(packet) {
  const excerpts = packet.excerpts.map((item) => `## ${item.path}\n\n\`\`\`text\n${item.excerpt}\n\`\`\``).join("\n\n");
  return `# Multiagent Evidence Packet

Task: ${packet.task_id}
Objective: ${packet.objective}
Branch: ${packet.branch}
Risk tier: ${packet.risk_tier}
Local verification required: yes

## Expected Output

${packet.expected_output}

## Stop Condition

${packet.stop_condition}

## Dirty State

\`\`\`text
${packet.dirty_state || "clean or not a git repo"}
\`\`\`

${excerpts}
`;
}

function git(args) {
  try {
    return execFileSync("git", args, { cwd: root, encoding: "utf8", stdio: ["ignore", "pipe", "ignore"] }).trim();
  } catch {
    return "";
  }
}

function slug(value) {
  return String(value).toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/^-|-$/g, "").slice(0, 80) || "task";
}

function rel(root, file) {
  return path.relative(root, file).replaceAll("\\", "/");
}

function fail(message) {
  console.error(JSON.stringify({ ok: false, error: message }, null, 2));
  process.exit(1);
}
