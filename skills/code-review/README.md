# code-review

Reviews code changes for correctness, security, and quality.

**Invoke:** `/code-review` or `/code-review <path>`

**Tools used:** Bash, Read, Glob, Grep

## What it does

1. Reads the diff of the current branch vs `main` (or a specific path)
2. Checks for bugs, security issues, missing error handling, test coverage
3. Returns structured findings: must-fix, should-fix, optional

## Output format

```
## Must fix 🔴
...

## Should fix 🟡
...

## Optional 🟢
...

Verdict: Approve / Approve with suggestions / Request changes
```
