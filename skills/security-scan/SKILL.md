---
name: Security Scan
description: Scans code changes for secrets, injection vectors, insecure defaults, and missing auth — returns a structured findings report
version: 1.0.0
user-invocable: true
allowed-tools:
  - Bash
  - Read
  - Grep
  - Glob
---

# Security Scan

> Automated security review of code changes. Finds hardcoded secrets, dangerous
> function calls, missing input validation, and other common vulnerabilities.

## When to use

Invoke with `/security-scan` before opening a PR, or with a path to review a
specific area: `/security-scan src/payments/`.

`$ARGUMENTS` = optional path or glob to scope the scan. If empty, scans the
entire diff of the current branch vs `main`.

---

## Step 1 — Load context

Read the following references before starting. They define what to look for
and the severity classifications used in the output.

```
Read: references/checklist.md    ← structured checklist of what to verify
Read: references/patterns.md     ← regex patterns and examples of bad code
```

---

## Step 2 — Determine scan scope

1. If `$ARGUMENTS` is non-empty, use it as the target path.
2. Otherwise run:
   ```bash
   git diff main...HEAD --name-only
   ```
   to get the list of changed files. If the branch has no changes vs `main`,
   tell the user and stop.

---

## Step 3 — Run the automated scanner

Run the scan script against the target:

```bash
bash scripts/scan.sh "$ARGUMENTS"
```

The script outputs findings in this format:
```
SEVERITY|FILE:LINE|PATTERN|SNIPPET
```

Capture the output — you will merge it with your manual review in Step 4.

If the script exits non-zero, it means a scan error occurred (not a finding).
Read stderr and report it to the user before continuing.

---

## Step 4 — Manual review

For each file in scope, additionally check these items that the script cannot
detect mechanically — refer to `references/checklist.md` for details:

- Authentication: are endpoints protected? Is auth bypassed anywhere?
- Authorization: does the code check that the caller has permission, not just identity?
- Error messages: do they leak internal paths, stack traces, or data?
- Dependencies: do any newly added packages have known CVEs?
- Logging: is sensitive data (tokens, PII, card numbers) written to logs?

---

## Step 5 — Produce the report

Combine automated findings (Step 3) with manual findings (Step 4).
Output exactly this format:

```
## Security Scan Report
Scope: <path or "branch diff">
Files scanned: <N>

---

### 🔴 Critical
(authentication bypass, secret exposure, RCE — must fix before merge)

- FILE:LINE — <description> — <remediation>

### 🟡 High
(SQL injection, missing auth checks, insecure deserialization)

- FILE:LINE — <description> — <remediation>

### 🟠 Medium
(error message leakage, weak crypto, missing rate limiting)

- FILE:LINE — <description> — <remediation>

### 🟢 Low / Informational
(style issues, minor hardening opportunities)

- FILE:LINE — <description> — <remediation>

---

**Verdict:** PASS / FAIL
_(FAIL if any Critical or High findings exist)_
```

If a severity section has no findings, write `None.`

---

## Rules

- **Never** mark a finding as low-severity to soften the report — call it what it is.
- **Always** include a concrete remediation suggestion, not just "fix this".
- If a pattern looks like a false positive (e.g. a token in a test fixture with a fake value), note it as `[possible FP]` but still include it.
- Do not scan files in `.git/`, `node_modules/`, or `__pycache__/`.
