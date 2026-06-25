# Skills Monorepo

Org-wide Claude Code skills (slash commands) — one directory per skill.

Each skill is a `SKILL.md` file with YAML frontmatter + instructions that Claude follows when the slash command is invoked.

## Structure

```
skills/
├── skills/           # one directory per skill (named = the /slash-command)
│   ├── create-pr/    # /create-pr
│   ├── code-review/  # /code-review
│   └── add-mcp/      # /add-mcp  (specific to our mcps monorepo)
└── templates/
    └── new-skill/    # copy this to add a skill
```

## Using skills in your project

### Option A — Symlink the whole collection

```bash
# From your project root
ln -s /path/to/skills/skills .claude/skills
```

### Option B — Copy a specific skill

```bash
mkdir -p .claude/skills
cp -r /path/to/skills/skills/create-pr .claude/skills/
```

### Option C — Git submodule

```bash
git submodule add <repo-url> .claude/skills-org
# Then symlink individual skills into .claude/skills/
```

Once a skill is inside `.claude/skills/` in your project, invoke it with:

```
/skill-name
/skill-name some arguments
```

## Adding a new skill

```bash
# 1. Copy the template
cp -r templates/new-skill skills/my-skill

# 2. Edit skills/my-skill/SKILL.md — update frontmatter + instructions
# 3. Add your team to .github/CODEOWNERS
# 4. Open a PR — CI validates the skill format automatically
```

## Skill anatomy

```
skills/my-skill/
├── SKILL.md        # required — frontmatter + instructions
├── README.md       # optional — human docs
├── scripts/        # optional — helper scripts Claude can run
└── references/     # optional — docs loaded into context on demand
```

## CI

On every PR, the validate workflow checks that each `SKILL.md`:
- Has valid YAML frontmatter
- Contains required fields: `name`, `description`, `version`
- Is not empty beyond the frontmatter
