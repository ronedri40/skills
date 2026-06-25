---
name: Skill Display Name          # shown in skill listings
description: One-line description of what this skill does and when to use it
version: 1.0.0
user-invocable: true              # false = only Claude invokes it automatically
allowed-tools:                    # tools Claude may use during this skill
  - Bash
  - Read
  - Write
  - Edit
  - Glob
  - Grep
---

# Skill Name

## When to use

Describe the exact conditions under which this skill should be invoked.
What problem does it solve? What triggers it?

Invoked with `/skill-name` or `/skill-name <arguments>`.
`$ARGUMENTS` contains whatever the user typed after the command name.

## Instructions

Step-by-step instructions for Claude. Be precise — Claude follows these literally.

1. First step.
2. Second step — reference `$ARGUMENTS` if the skill accepts input.
3. Third step.
4. Return a clear result to the user.

## Rules

- List any hard constraints here (e.g. "never delete files without confirmation").
- List what Claude must NOT do.
- List what Claude must always do.

## Output format

Describe the expected shape of Claude's response, if it has a specific structure.
