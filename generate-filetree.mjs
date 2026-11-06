#!/usr/bin/env node
// generate-filetree.mjs
//
// Usage:  node generate-filetree.mjs
//
// Rewrites the table between <!-- FILE_TREE_START --> and <!-- FILE_TREE_END --> in README.md.
// Git dates need `actions/checkout` with `fetch-depth: 0` in CI.

import fs from "fs";
import path from "path";
import { execFileSync } from "child_process";

// ── Config ────────────────────────────────────────────────────────────────────

const SHOW_DATES = false; // last commit date next to each link

const INCLUDE_EXTENSIONS = new Set([".pdf", ".md", ".txt", ".docx", ".xlsx", ".csv"]);
const SKIP_DIRS = new Set([".git", ".github", "node_modules", "__pycache__", ".venv", "venv", "dist", "build"]);

// Optional readable course names. Unlisted codes just show the code.
const COURSES = {
  // INFODB: "Databases",
  // INFOFP: "Functional Programming",
};

// Folder type (the part after "[CODE] ") -> column. Anything else goes to "Other".
const COLUMNS = [
  { key: "summary",     title: "📚 Summaries",   single: "Summary",    types: ["Samenvatting"] },
  { key: "assignments", title: "📝 Assignments", single: "Assignment", types: ["Opdracht"] },
  { key: "other",       title: "📎 Other",       single: "",           types: [] },
];

const REPO     = process.env.GITHUB_REPOSITORY ?? "MattterSteege/latex-projecten";
const BRANCH   = process.env.GITHUB_REF_NAME   ?? "master";
const BASE_URL = `https://github.com/${REPO}/blob/${BRANCH}`;
const ROOT     = process.cwd();
const README   = path.join(ROOT, "README.md");

// ── Helpers ───────────────────────────────────────────────────────────────────

const urlFor = rel => `${BASE_URL}/${rel.split("/").map(encodeURIComponent).join("/")}`;
const esc    = s   => s.replace(/\|/g, "\\|");
const plural = (n, w) => `${n} ${w}${n === 1 ? "" : "s"}`;

function walkFiles(dir, rel = "") {
  let entries;
  try { entries = fs.readdirSync(dir, { withFileTypes: true }); } catch { return []; }
  return entries
    .filter(e => !SKIP_DIRS.has(e.name) && !e.name.startsWith("."))
    .sort((a, b) => a.name.localeCompare(b.name, undefined, { numeric: true, sensitivity: "base" }))
    .flatMap(e => {
      const r = rel ? `${rel}/${e.name}` : e.name;
      if (e.isDirectory()) return walkFiles(path.join(dir, e.name), r);
      return INCLUDE_EXTENSIONS.has(path.extname(e.name).toLowerCase()) ? [r] : [];
    });
}

function gitDate(rel) {
  try {
    return execFileSync("git", ["log", "-1", "--format=%cs", "--", rel], {
      encoding: "utf8",
      stdio: ["ignore", "pipe", "ignore"],
    }).trim();
  } catch {
    return "";
  }
}

// ── Collect ───────────────────────────────────────────────────────────────────

const topDirs = fs.readdirSync(ROOT, { withFileTypes: true })
  .filter(e => e.isDirectory() && !SKIP_DIRS.has(e.name) && !e.name.startsWith("."));

const courses = new Map(); // code -> { code, name, cols: { summary: [], ... } }
let fileCount = 0;

for (const dir of topDirs) {
  const m = dir.name.match(/^\[([A-Za-z0-9]+)\]\s*(.+)$/);
  const code = m ? m[1].toUpperCase() : "—";
  const type = m ? m[2].trim() : dir.name;
  const col  = COLUMNS.find(c => c.types.some(t => t.toLowerCase() === type.toLowerCase()))
            ?? COLUMNS.at(-1);

  for (const rel of walkFiles(path.join(ROOT, dir.name), dir.name)) {
    const inner  = rel.split("/").slice(1).join("/").replace(/\.[^.]+$/, "");
    const isMain = inner.toLowerCase() === "main";

    let label;
    if (col.key === "other") label = isMain ? type : `${type}: ${inner}`;
    else label = isMain ? col.single : inner;

    if (!courses.has(code)) {
      courses.set(code, {
        code,
        name: COURSES[code] ?? "",
        cols: Object.fromEntries(COLUMNS.map(c => [c.key, []])),
      });
    }

    const icon = rel.toLowerCase().endsWith(".pdf") ? "📕" : "📄";
    const date = SHOW_DATES ? gitDate(rel) : "";
    courses.get(code).cols[col.key].push(
      `${icon} [${esc(label)}](${urlFor(rel)})${date ? ` <sub>${date}</sub>` : ""}`
    );
    fileCount++;
  }
}

// ── Render ────────────────────────────────────────────────────────────────────

const list = [...courses.values()].sort((a, b) => a.code.localeCompare(b.code));

const head = `| Course | ${COLUMNS.map(c => c.title).join(" | ")} |`;
const sep  = `|:--|${COLUMNS.map(() => ":--").join("|")}|`;
const rows = list.map(c => {
  const name  = c.name ? `**${c.code}**<br>${c.name}` : `**${c.code}**`;
  const cells = COLUMNS.map(col => c.cols[col.key].join("<br>") || "·");
  return `| ${name} | ${cells.join(" | ")} |`;
});

const table = [
  `_${plural(fileCount, "document")} across ${plural(list.length, "course")}_`,
  "",
  head,
  sep,
  ...rows,
].join("\n");

// ── Write README ──────────────────────────────────────────────────────────────

const section = `<!-- FILE_TREE_START -->\n${table}\n<!-- FILE_TREE_END -->`;

let content = fs.existsSync(README)
  ? fs.readFileSync(README, "utf8")
  : `# ${path.basename(ROOT)}\n\n## 📂 Samenvatting en opdrachten\n\n`;

const marker = /<!-- FILE_TREE_START -->[\s\S]*?<!-- FILE_TREE_END -->/;
content = marker.test(content)
  ? content.replace(marker, () => section)
  : content.trimEnd() + "\n\n## 📂 Samenvatting en opdrachten\n\n" + section + "\n";

fs.writeFileSync(README, content, "utf8");
console.log(`✅ README.md updated — ${fileCount} files, ${list.length} courses.`);
