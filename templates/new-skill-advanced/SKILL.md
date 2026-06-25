---
# ── Identity ──────────────────────────────────────────────────────────────────
name: Skill Display Name          # shown in /skills list and logs
description: >
  One-line description of what this skill does and when to invoke it.
  Keep it under 120 characters so it fits in autocomplete.
version: 1.0.0

# ── Invocation ────────────────────────────────────────────────────────────────
user-invocable: true              # false = Claude invokes this autonomously only

# ── Tools Claude may use during this skill ────────────────────────────────────
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Glob
  - Grep

# ── Proactive trigger (optional) ──────────────────────────────────────────────
# If set, Claude considers invoking this skill automatically when the
# user's message matches. Remove the key if you don't need auto-invocation.
trigger: "when the user asks to <do X> or mentions <keyword>"
---

# Skill Name

> One-sentence summary of what this skill does.

## When to use

Describe the exact scenarios that should trigger this skill.
Be concrete — Claude matches against these conditions.

Invoked as: `/skill-name` or `/skill-name <arguments>`

`$ARGUMENTS` contains everything the user typed after the command name.
If no arguments are expected, omit `$ARGUMENTS` references below.

---

## Step 1 — Load context

Before starting, read these files into your context.
Only load what you actually need for the current invocation.

```
Read: references/conventions.md      ← org conventions for this skill
Read: references/checklist.md        ← validation checklist to apply
```

---

## Step 2 — Validate preconditions

Check that the environment is ready before doing any work:

1. Verify `$ARGUMENTS` is not empty. If it is, ask the user for the required input.
2. Check that required tools / CLIs are available (e.g. `which gh`, `which uv`).
3. If any check fails, stop and explain what the user needs to fix.

---

## Step 3 — Core logic

Describe the main steps Claude should execute.
Reference helper scripts where they save time or ensure consistency.

1. Do the first thing.
2. Run the validation script:
   ```bash
   bash scripts/validate.sh "$ARGUMENTS"
   ```
   If the script exits non-zero, read its output, explain the problem, and stop.
3. Do the next thing.
4. Run the analysis script if needed:
   ```bash
   python3 scripts/analyze.py "$ARGUMENTS"
   ```

---

## Step 4 — Output

Describe exactly what Claude should return to the user.

Structure the response as:

```
## Result
<summary of what was done>

## Details
<any relevant details, file paths, IDs>

## Next steps
<what the user should do next, if anything>
```

---

## Rules

List hard constraints — things Claude must ALWAYS or NEVER do.

- **Always** confirm before making irreversible changes (deleting, force-pushing).
- **Never** commit secrets or credentials.
- **Never** skip pre-commit hooks.
- If uncertain about a step, ask the user rather than guessing.
