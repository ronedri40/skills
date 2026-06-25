---
name: Create PR
description: Creates a pull request with a structured description, test plan, and proper git hygiene
version: 1.0.0
user-invocable: true
allowed-tools:
  - Bash
  - Read
---

# Create PR

## When to use

Invoke with `/create-pr` when you are ready to open a pull request for the current branch.
Optionally pass a title hint: `/create-pr fix login timeout`.

## Instructions

1. Run `git status` — verify the working tree is clean. If not, tell the user what is uncommitted and stop.
2. Run `git log main...HEAD --oneline` to understand what commits will be in the PR.
3. Run `git diff main...HEAD` to review all changes.
4. Derive a short, imperative PR title (under 70 characters). If `$ARGUMENTS` was provided, use it as the title directly.
5. Write a PR body using the template below.
6. If the branch has no upstream, push it: `git push -u origin HEAD`.
7. Create the PR: `gh pr create --title "<title>" --body "<body>"`.
8. Return the PR URL to the user.

## PR body template

```
## Summary
- 

## Test plan
- [ ] 
- [ ] 

🤖 Generated with Claude Code
```

## Rules

- Never force-push.
- Never skip pre-commit hooks (`--no-verify`).
- Always confirm before creating a PR targeting `main` or `master` directly.
- If the PR already exists for this branch, offer to update its description instead.
