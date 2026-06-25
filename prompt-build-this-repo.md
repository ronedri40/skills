# Prompt: Build the Skills Monorepo from Scratch

Paste this entire prompt into a new Claude Code session in an empty directory.

---

Build a Claude Code skills monorepo from scratch in the current directory.
Follow every decision below exactly — do not improvise alternatives.

## What this repo is

A monorepo of Claude Code skills (slash commands) that any team can use in their projects.
A **skill** is a directory containing a `SKILL.md` file — YAML frontmatter that tells Claude
how to behave, plus markdown instructions Claude follows step-by-step when the command runs.

Skills live in `skills/<command-name>/` where `command-name` = what users type after `/`.
Example: `skills/create-pr/` → invoked with `/create-pr`.

This repo contains:
- 4 ready-to-use skills (create-pr, code-review, add-mcp, security-scan)
- 2 templates (simple and advanced)
- CI that validates every SKILL.md has correct frontmatter
- A comprehensive README that serves as the org guide for authoring skills

---

## Full directory structure to create

```
skills/
├── .gitignore
├── README.md                          ← comprehensive authoring guide (see spec below)
│
├── skills/
│   ├── create-pr/
│   │   ├── SKILL.md
│   │   └── README.md
│   │
│   ├── code-review/
│   │   ├── SKILL.md
│   │   └── README.md
│   │
│   ├── add-mcp/
│   │   ├── SKILL.md
│   │   └── README.md
│   │
│   └── security-scan/                 ← demo of the advanced structure
│       ├── SKILL.md
│       ├── README.md
│       ├── scripts/
│       │   └── scan.sh                ← bash scanner (executable)
│       └── references/
│           ├── checklist.md           ← manual review checklist
│           └── patterns.md            ← vulnerable code pattern examples
│
├── templates/
│   ├── new-skill/                     ← simple template
│   │   ├── SKILL.md
│   │   └── README.md
│   │
│   └── new-skill-advanced/            ← full template with scripts + references
│       ├── SKILL.md
│       ├── README.md
│       ├── scripts/
│       │   ├── validate.sh
│       │   └── analyze.py
│       └── references/
│           ├── conventions.md
│           └── checklist.md
│
└── .github/
    ├── CODEOWNERS
    └── workflows/
        └── validate.yml
```

---

## SKILL.md format

Every `SKILL.md` has two parts:

### 1. YAML frontmatter (required fields: name, description, version)

```yaml
---
name: Human Readable Name
description: One-line summary of what this skill does (under 120 chars)
version: 1.0.0
user-invocable: true        # false = Claude auto-invokes only
allowed-tools:              # only list tools the skill actually needs
  - Bash
  - Read
  - Write
  - Edit
  - Glob
  - Grep
---
```

### 2. Markdown body

Plain markdown. Claude reads this literally. Sections to include:
- **When to use** — exact trigger conditions
- **Step N — ...** — numbered phases of the skill
- **Rules** — hard constraints (never/always)
- **Output format** — expected shape of response

`$ARGUMENTS` = everything the user typed after the command name.

---

## Skill specifications

### `skills/create-pr/SKILL.md`

Frontmatter: name="Create PR", allowed-tools=[Bash, Read], user-invocable=true

Instructions:
1. Run `git status` — stop if working tree is dirty.
2. Run `git log main...HEAD --oneline` to understand the commits.
3. Run `git diff main...HEAD` to review all changes.
4. Derive a short imperative PR title (under 70 chars). Use `$ARGUMENTS` as title if provided.
5. Write PR body with Summary (2–4 bullets) and Test plan (checkboxes).
6. Push branch if no upstream: `git push -u origin HEAD`.
7. Create PR: `gh pr create --title "..." --body "..."` and return the URL.

Rules: never force-push, never `--no-verify`, always confirm before targeting main/master directly.

---

### `skills/code-review/SKILL.md`

Frontmatter: name="Code Review", allowed-tools=[Bash, Read, Glob, Grep], user-invocable=true

Instructions:
1. If `$ARGUMENTS` provided → review those paths. Otherwise → `git diff main...HEAD`.
2. For each changed file check: correctness, security, error handling, test coverage, style.
3. Output in three sections:
   - `## Must fix 🔴` — bugs, security (blocking)
   - `## Should fix 🟡` — quality, missing tests
   - `## Optional 🟢` — style suggestions
4. Each finding: file:line — one-sentence explanation — concrete suggestion.
5. End with verdict: **Approve** / **Approve with suggestions** / **Request changes**.

Rules: be specific (no "this could be cleaner"), only flag real issues, note false positives as `[possible FP]`.

---

### `skills/add-mcp/SKILL.md`

Frontmatter: name="Add MCP Server", allowed-tools=[Bash, Read, Write, Edit, Glob], user-invocable=true

Purpose: scaffolds a new domain MCP server in the org `mcps` monorepo.
Invoked as `/add-mcp <domain>` (e.g. `/add-mcp jira`).

Instructions:
1. Read `$ARGUMENTS` as the domain name. Ask if empty.
2. Verify in mcps repo root: `pyproject.toml` must contain `[tool.uv.workspace]`.
3. Check `servers/<domain>/` does not already exist.
4. `cp -r templates/new-server servers/<domain>`
5. `mv servers/<domain>/src/server_name_mcp servers/<domain>/src/<domain>_mcp`
6. In `servers/<domain>/pyproject.toml`: update name, description, script entry point.
7. In `server.py`: replace all `server_name_mcp` → `<domain>_mcp`, update display name.
8. In `Dockerfile`: replace all DOMAIN placeholders.
9. In tool/resource/prompt files: update imports.
10. Run `uv sync`.
11. Validate: `uv run --package <domain>-mcp python -c "from <domain>_mcp.server import mcp; print(mcp)"`
12. Tell user: implement tools, add to CODEOWNERS, add to docker-compose.yml.

---

### `skills/security-scan/SKILL.md` ← advanced structure demo

Frontmatter: name="Security Scan", allowed-tools=[Bash, Read, Grep, Glob], user-invocable=true

Description: Scans code changes for secrets, injection vectors, insecure defaults, and missing
auth — returns a structured findings report.

Instructions (5 steps — reference scripts and references explicitly):

**Step 1 — Load context**
```
Read: references/checklist.md
Read: references/patterns.md
```

**Step 2 — Determine scope**
- If `$ARGUMENTS` non-empty → use as target path
- Else → `git diff main...HEAD --name-only`

**Step 3 — Run automated scanner**
```bash
bash scripts/scan.sh "$ARGUMENTS"
```
Script outputs: `SEVERITY|FILE:LINE|PATTERN|SNIPPET` (one per line).
If exits non-zero → scan error, report and stop.

**Step 4 — Manual review**
Using `references/checklist.md`, check: authentication gaps, authorization gaps,
error message leakage, new dependency CVEs, sensitive data in logs.

**Step 5 — Produce report**
```
## Security Scan Report
Scope: <path or "branch diff">
Files scanned: <N>

### 🔴 Critical
### 🟡 High
### 🟠 Medium
### 🟢 Low / Informational

Verdict: PASS / FAIL
(FAIL if any Critical or High findings)
```

---

### `skills/security-scan/scripts/scan.sh`

A real bash script (set -euo pipefail) that:
- Accepts optional `$1` as target path or uses git diff files
- Uses `grep -n` to scan each file for patterns
- Emits findings as `SEVERITY|FILE:LINE|PATTERN|SNIPPET`
- Detects: hardcoded secrets (password/api_key/token = "..."), private key PEM headers,
  shell injection (os.system, shell=True, eval(), exec()), SQL string concatenation
  (SELECT... + variable), error detail leakage (str(e) in response, traceback.print_exc),
  hardcoded local URLs, security TODOs
- Prints `SCAN_START|files=N` and `SCAN_END|findings=N` as bookends
- Exits 0 always (findings are not errors); exits 1 only on scan setup errors

Make the script executable (chmod +x).

---

### `skills/security-scan/references/checklist.md`

A structured security review checklist with these 8 sections:
Authentication, Authorization, Input validation, Secrets and configuration,
Data exposure, Dependencies, Cryptography, Rate limiting and abuse prevention.

Each section has 4–6 checkbox items that Claude works through during manual review.
Keep items concrete and checkable — not vague.

---

### `skills/security-scan/references/patterns.md`

Before/after code examples for each vulnerability category:
Hardcoded secrets, Shell injection, SQL injection, Error detail leakage,
Path traversal, Insecure TLS, Unsafe deserialization.

End with a severity quick reference table:
- 🔴 Critical: hardcoded prod secret, RCE, auth bypass
- 🟡 High: SQL injection, missing auth, insecure deserialization
- 🟠 Medium: error leak, weak crypto, hardcoded local URL
- 🟢 Low: security TODO, over-broad CORS, verbose logging

---

## Template specifications

### `templates/new-skill/SKILL.md`

A minimal template with every frontmatter field shown and commented.
Body has placeholder sections: When to use, Instructions (steps), Rules, Output format.
Include a note explaining `$ARGUMENTS`.

### `templates/new-skill-advanced/SKILL.md`

Full template showing ALL features:
- Complete frontmatter with comments on every field including optional `trigger:`
- Step 1: explicit "Load context" section with `Read: references/X.md` examples
- Step 2: precondition validation (check $ARGUMENTS, check required CLIs)
- Step 3: core logic with `bash scripts/validate.sh "$ARGUMENTS"` example
- Step 4: output section with structured response format
- Rules section

### `templates/new-skill-advanced/scripts/validate.sh`
Bash script skeleton (set -euo pipefail) that accepts `$1`, validates it non-empty,
checks it exists, exits 0 on pass with "OK: validation passed".

### `templates/new-skill-advanced/scripts/analyze.py`
Python script skeleton with `main() -> int`, accepts `sys.argv[1]`, prints structured
findings to stdout, exits 0 on success.

### `templates/new-skill-advanced/references/conventions.md`
Example conventions reference covering: naming (kebab-case files, snake_case Python),
code style (line length, type annotations), git (branch naming, commit format).
Include a tip: keep files short — they are loaded into Claude's context window.

### `templates/new-skill-advanced/references/checklist.md`
Example checklist with: pre-completion checks (inputs validated, no secrets in output,
irreversible actions confirmed) and output quality checks (summary is actionable, paths
are clear, next steps are concrete).

---

## `README.md` — comprehensive authoring guide

The README must cover all of these sections:

1. **What is a Claude Code skill?** (3-4 sentences on how SKILL.md works)
2. **Repository structure** — annotated tree showing every directory's purpose
3. **SKILL.md anatomy** — frontmatter fields table + body section conventions table
4. **Supporting files** — table: scripts/ purpose, references/ purpose
5. **Choosing a template** — table: simple vs advanced, when to use each
6. **Adding a new skill — step by step**:
   - Pick a name (kebab-case = slash command)
   - Copy the right template
   - Edit SKILL.md (frontmatter + body)
   - Edit README.md
   - (Advanced) Add scripts and references — show how to reference them in SKILL.md
   - Add team to CODEOWNERS
   - Open a PR
7. **Using skills in your project** — three options:
   - Option A: `ln -s /path/to/skills/skills .claude/skills` (symlink whole collection)
   - Option B: git submodule + selective symlinks
   - Option C: copy a specific skill (for project-local customisation)
8. **CI** — what the validator checks

---

## `.github/workflows/validate.yml`

Triggers on PRs that touch `skills/**` or `templates/**`.

Two jobs:
1. **Check every skill has a SKILL.md** — bash loop over `skills/*/`, fail if any missing
2. **Validate required frontmatter fields** — Python script using `pyyaml` (installed via pip):
   - Parse frontmatter between `---` markers
   - Verify `name`, `description`, `version` all present
   - Print `OK: <path>` for passing skills, `ERROR: <path> — <reason>` for failures
   - Exit 1 if any failures

---

## `.github/CODEOWNERS`

```
skills/create-pr/      @org/platform-infra
skills/code-review/    @org/platform-infra
skills/add-mcp/        @org/platform-infra
skills/security-scan/  @org/platform-infra
templates/             @org/platform-infra
.github/               @org/platform-infra
```

---

## After building

1. `git init && git add -A && git commit -m "feat: initial skills monorepo scaffold"`
2. Verify validate workflow logic works: `python3` the frontmatter check script locally
3. Verify scan.sh is executable: `bash skills/security-scan/scripts/scan.sh`
