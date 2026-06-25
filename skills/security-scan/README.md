# security-scan

Scans code changes for secrets, injection vectors, insecure defaults, and missing auth.
Returns a structured findings report with severity levels and remediation suggestions.

**Invoke:** `/security-scan` or `/security-scan <path>`

**Tools used:** Bash, Read, Grep, Glob

**Owner:** @org/platform-infra

---

## What it does

1. Loads the security checklist and pattern reference into context
2. Determines scope: explicit path, or the branch diff vs `main`
3. Runs `scripts/scan.sh` — automated grep-based detection of known-bad patterns
4. Manual review by Claude against the checklist (auth, authz, error leakage, deps, crypto)
5. Produces a structured report: Critical / High / Medium / Low findings + PASS/FAIL verdict

## Files in this skill

| File | Purpose |
|---|---|
| `SKILL.md` | Step-by-step instructions Claude follows |
| `scripts/scan.sh` | Automated scanner — greps for secrets, injection, unsafe calls |
| `references/checklist.md` | Manual review checklist (auth, authz, input validation, secrets, deps) |
| `references/patterns.md` | Vulnerable pattern examples with fixes for each category |

## Example output

```
## Security Scan Report
Scope: src/payments/
Files scanned: 4

---

### 🔴 Critical
- src/payments/client.py:12 — hardcoded Stripe secret key — move to STRIPE_API_KEY env var

### 🟡 High
None.

### 🟠 Medium
- src/payments/errors.py:34 — exception detail leaked in API response — return generic message

### 🟢 Low
None.

---

Verdict: FAIL
```

## What the scanner catches automatically

- Hardcoded secrets (passwords, API keys, tokens)
- Private key material
- Shell injection (`os.system`, `shell=True`, `eval`)
- SQL string concatenation
- Error detail leakage (`str(e)` in responses)
- Hardcoded local URLs
- Security-related TODOs/FIXMEs

## What Claude catches manually (checklist)

- Authentication gaps (unprotected endpoints)
- Authorization gaps (ownership not verified)
- Input validation (path traversal, unbounded integers)
- Dependency CVEs (newly added packages)
- Cryptographic weaknesses (MD5 passwords, `verify=False`)
- Rate limiting gaps
