#!/usr/bin/env node
// generate-filetree.mjs
// Run locally:  node generate-filetree.mjs
// Run in CI:    node generate-filetree.mjs (env vars set automatically by GitHub Actions)

import fs from "fs";
import path from "path";

// ── Config ────────────────────────────────────────────────────────────────────

const INCLUDE_EXTENSIONS = new Set([
  ".pdf", ".md", ".txt", ".docx", ".xlsx", ".csv",
  ".png", ".jpg", ".jpeg", ".gif", ".svg",
]);

const SKIP_DIRS = new Set([
  ".git", ".github", "node_modules", "__pycache__", ".venv", "venv", "dist", "build",
]);

const REPO      = process.env.GITHUB_REPOSITORY ?? "MattterSteege/latex-projecten";   // e.g. "myuser/my-repo"
const BRANCH    = process.env.GITHUB_REF_NAME   ?? "master";
const BASE_URL  = `https://github.com/${REPO}/blob/${BRANCH}`;
const ROOT      = process.cwd();
const README    = path.join(ROOT, "README.md");

// ── Tree builder ──────────────────────────────────────────────────────────────

function buildTree(dir, prefix = "", relPath = "") {
  const lines = [];

  let entries;
  try {
    entries = fs.readdirSync(dir, { withFileTypes: true });
  } catch {
    return lines;
  }

  entries = entries
    .filter(e => !SKIP_DIRS.has(e.name) && !e.name.startsWith("."))
    .sort((a, b) => {
      // Folders first, then files; both alphabetical
      if (a.isDirectory() !== b.isDirectory()) return a.isDirectory() ? -1 : 1;
      return a.name.localeCompare(b.name, undefined, { sensitivity: "base" });
    });

  entries.forEach((entry, i) => {
    const isLast   = i === entries.length - 1;
    const connector = isLast ? "└── " : "├── ";
    const childPfx  = isLast ? "&nbsp;&nbsp;&nbsp;&nbsp;" : "│&nbsp;&nbsp;&nbsp;";
    const rel       = relPath ? `${relPath}/${entry.name}` : entry.name;

    if (entry.isDirectory()) {
      lines.push(`${prefix}${connector}📁 **${entry.name}**`);
      lines.push(...buildTree(path.join(dir, entry.name), prefix + childPfx, rel));
    } else {
      const ext = path.extname(entry.name).toLowerCase();
      if (INCLUDE_EXTENSIONS.has(ext)) {
        const url  = `${BASE_URL}/${rel.split("/").map(s => encodeURIComponent(s)).join("/")}`;
        const icon = ext === ".pdf" ? "📕" : "📄";
        lines.push(`${prefix}${connector}${icon} [${entry.name}](${url})`);
      }
    }
  });

  return lines;
}

// ── Main ──────────────────────────────────────────────────────────────────────

const treeLines = buildTree(ROOT);
const treeBlock = treeLines.length ? treeLines.join("<br>\n") : "_No files found._";

const section = [
  "## 📂 Samenvatting en opdrachten",
  "Dit zijn alle samenvattingen en opdrachten die ik (met anderen) gemaakt heb voor de vakken die ik volg.",
  "Geniet er van!",
  "",
  "<!-- FILE_TREE_START -->",
  treeBlock,
  "<!-- FILE_TREE_END -->",
  "",
].join("\n");

let content = fs.existsSync(README)
  ? fs.readFileSync(README, "utf8")
  : `# ${path.basename(ROOT)}\n\n`;

const marker = /## 📂 Repository Structure\r?\n\r?\n<!-- FILE_TREE_START -->[\s\S]*?<!-- FILE_TREE_END -->\r?\n?/;

content = marker.test(content)
  ? content.replace(marker, section)
  : content.trimEnd() + "\n\n" + section;

fs.writeFileSync(README, content, "utf8");
console.log("✅ README.md updated.");
