---
name: Code Review
description: Reviews code changes for bugs, security issues, missing tests, and style problems
version: 1.0.0
user-invocable: true
allowed-tools:
  - Bash
  - Read
  - Glob
  - Grep
---

# Code Review

## When to use

Invoke with `/code-review` to review the current branch's changes against `main`.
Optionally pass a specific path: `/code-review src/payments/`.

## Instructions

1. Determine the scope:
   - If `$ARGUMENTS` is provided → review those specific files/paths only.
   - Otherwise → run `git diff main...HEAD --name-only` to get all changed files, then `git diff main...HEAD` for the full diff.
2. For each changed file, evaluate:
   - **Correctness** — logic bugs, off-by-one errors, wrong conditionals
   - **Security** — SQL injection, hardcoded secrets, insecure defaults, missing input validation
   - **Error handling** — uncaught exceptions, unhandled edge cases, missing status checks
   - **Test coverage** — new behavior should have tests; check if tests exist alongside the change
   - **Style** — naming, dead code, overly complex expressions
3. Output findings in three sections:

```
## Must fix 🔴
(blocking issues — bugs, security)

## Should fix 🟡
(quality issues — missing tests, unclear logic)

## Optional 🟢
(style suggestions, minor improvements)
```

4. For each finding include: file path + line number, a one-sentence explanation, and a concrete suggestion.
5. End with a one-line verdict: **Approve**, **Approve with suggestions**, or **Request changes**.

## Rules

- Be specific — no vague comments like "this could be cleaner".
- Only flag real issues, not personal style preferences.
- If a section has no findings, write "None."
