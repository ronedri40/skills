# Conventions

This file is loaded by the skill at runtime to give Claude org-specific context.
Replace this content with your actual conventions.

## Naming

- Use kebab-case for file names and command names.
- Use snake_case for Python identifiers.
- Prefix internal tools with `_` to signal they are not user-facing.

## Code style

- Max line length: 100 characters.
- Always add type annotations to function signatures.
- Prefer explicit over implicit.

## Git

- Branch naming: `<type>/<short-description>` (e.g. `feat/add-charge-tool`).
- Commit messages: imperative mood, under 72 characters.
- PR titles: same as commit message format.

---

> Tip: keep this file short — Claude loads it into its context window on every invocation.
> If the reference is large, split it into multiple files and load only what the current
> step needs.
