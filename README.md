# Skills Monorepo

Org-wide Claude Code skills — reusable slash commands that any team can drop into their project.

A **skill** is a directory containing a `SKILL.md` file. That file has two parts: a YAML frontmatter header that tells Claude when and how to run the skill, and markdown instructions that Claude follows step by step when the command is invoked.

---

## What is a Claude Code skill?

When you type `/create-pr` in Claude Code, it looks for a `SKILL.md` file named `create-pr` inside `.claude/skills/` in your project. It reads the frontmatter to understand what tools it is allowed to use, then executes the instructions in the markdown body.

Skills are more powerful than plain slash commands because they support:

- **Supporting files** — `scripts/` for shell/Python helpers Claude can run, `references/` for docs loaded on demand
- **Frontmatter control** — restrict which tools Claude may use, mark a skill as auto-invocable
- **Progressive disclosure** — instructions tell Claude to `Read: references/X.md` only when that section is needed, keeping the context window lean

---

## Repository structure

```
skills/
│
├── skills/                        ← one directory per slash command
│   ├── create-pr/                 # /create-pr
│   │   ├── SKILL.md               # instructions + frontmatter
│   │   └── README.md              # human docs
│   │
│   ├── code-review/               # /code-review
│   │   ├── SKILL.md
│   │   └── README.md
│   │
│   └── add-mcp/                   # /add-mcp  (scaffolds a new MCP server)
│       ├── SKILL.md
│       └── README.md
│
├── templates/
│   ├── new-skill/                 ← simple template (SKILL.md + README only)
│   │   ├── SKILL.md
│   │   └── README.md
│   │
│   └── new-skill-advanced/        ← full template (scripts + references)
│       ├── SKILL.md
│       ├── README.md
│       ├── scripts/
│       │   ├── validate.sh        # pre-flight validation helper
│       │   └── analyze.py         # analysis helper
│       └── references/
│           ├── conventions.md     # org conventions Claude loads for context
│           └── checklist.md       # self-verification checklist
│
└── .github/
    ├── CODEOWNERS                 # team ownership per skill
    └── workflows/
        └── validate.yml           # CI: checks frontmatter on every PR
```

---

## SKILL.md anatomy

Every skill needs exactly one `SKILL.md`. Here is what each part does:

### Frontmatter (required)

```yaml
---
name: Human Readable Name     # shown in /skills list and logs
description: One-line summary # what does this skill do?
version: 1.0.0                # bump when you make breaking changes

user-invocable: true          # true = user types /skill-name
                              # false = Claude invokes it automatically

allowed-tools:                # tools Claude MAY use — list only what is needed
  - Bash
  - Read
  - Write
  - Edit
  - Glob
  - Grep

trigger: "optional pattern"   # if set, Claude auto-invokes when this matches
---
```

### Body (required)

Plain markdown. Claude reads this literally and follows it as a step-by-step guide.

**Conventions used in this repo:**

| Section | Purpose |
|---|---|
| **When to use** | Exact conditions that trigger the skill |
| **Context loading** | Which `references/` files to `Read` before starting |
| **Step N — …** | One numbered section per major phase of the skill |
| **Rules** | Hard constraints — what Claude must always/never do |
| **Output format** | Expected shape of Claude's response |

### Supporting files (optional)

| Directory | What goes here |
|---|---|
| `scripts/` | Shell or Python scripts Claude runs via `Bash`. Keep them focused — one purpose per file. |
| `references/` | Docs Claude loads on demand with `Read`. Prefer many small files over one large one. |

---

## Choosing a template

| Template | Use when |
|---|---|
| `templates/new-skill/` | Simple skill — a few steps, no external scripts needed |
| `templates/new-skill-advanced/` | Complex skill — needs helper scripts, org reference docs, a checklist |

---

## Adding a new skill — step by step

### 1. Pick a name

The directory name becomes the slash command. Use kebab-case.

```
/create-pr       →  skills/create-pr/
/deploy-staging  →  skills/deploy-staging/
/add-mcp         →  skills/add-mcp/
```

### 2. Copy the right template

```bash
# Simple skill
cp -r templates/new-skill skills/my-skill

# Skill that needs scripts or references
cp -r templates/new-skill-advanced skills/my-skill
```

### 3. Edit SKILL.md

Open `skills/my-skill/SKILL.md` and update:

- `name` — human-readable display name
- `description` — one-line summary (under 120 characters)
- `allowed-tools` — remove tools the skill doesn't need
- **Body** — replace the placeholder sections with real instructions

### 4. Edit README.md

Fill in the human-readable docs: what it does, how to invoke it, what output to expect.

### 5. (Advanced) Add scripts and references

```bash
# Add a helper script
vim skills/my-skill/scripts/my-helper.sh
chmod +x skills/my-skill/scripts/my-helper.sh

# Add a reference doc
vim skills/my-skill/references/my-context.md
```

Reference them in `SKILL.md`:

```markdown
Run: bash scripts/my-helper.sh "$ARGUMENTS"
Read: references/my-context.md
```

### 6. Register ownership

Add your team to `.github/CODEOWNERS`:

```
skills/my-skill/   @org/your-team
```

### 7. Open a PR

CI runs automatically and validates your `SKILL.md` has correct frontmatter.
Once merged, the skill is available to all projects that link this repo.

---

## Using skills in your project

### Option A — Symlink the whole collection (recommended)

```bash
# From your project root
mkdir -p .claude
ln -s /path/to/skills/skills .claude/skills
```

All skills in this repo become available immediately. New skills added here
appear in your project without any action.

### Option B — Git submodule

```bash
# Add this repo as a submodule
git submodule add <repo-url> .claude/skills-org

# Symlink individual skills you want
mkdir -p .claude/skills
ln -s ../.claude/skills-org/create-pr .claude/skills/create-pr
```

### Option C — Copy a specific skill

```bash
mkdir -p .claude/skills
cp -r /path/to/skills/skills/create-pr .claude/skills/
```

Use this when you want to customise a skill for your project without affecting the org copy.

### Invoking skills

Once a skill is inside `.claude/skills/` in your project:

```
/create-pr
/code-review src/payments/
/add-mcp jira
```

---

## CI

The `validate.yml` workflow runs on every PR that touches `skills/` or `templates/`.

It checks that every `SKILL.md`:
- Has valid YAML frontmatter between `---` markers
- Contains the required fields: `name`, `description`, `version`
- Has content beyond the frontmatter

The validator is a small Python script in `.github/workflows/validate.yml` — no external dependencies.
