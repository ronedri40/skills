# create-pr

Creates a pull request with a structured description and test plan.

**Invoke:** `/create-pr` or `/create-pr <title>`

**Tools used:** Bash, Read

## What it does

1. Verifies the working tree is clean
2. Reads the diff vs `main`
3. Writes a structured PR body (summary + test plan)
4. Pushes the branch if needed
5. Opens the PR via `gh pr create`

## Requirements

- `gh` CLI must be authenticated
- Branch must differ from `main`
