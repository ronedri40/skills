# skill-name

One-line description of what this skill does.

**Invoke:** `/skill-name` or `/skill-name <argument>`

**Tools used:** Bash, Read, Write, Edit, Glob, Grep

**Owner:** @org/team-name

---

## What it does

Short description of the skill's behaviour (3–5 sentences).

Explain:
- What problem it solves
- What input it needs
- What output it produces

## Files in this skill

| File | Purpose |
|---|---|
| `SKILL.md` | Instructions Claude follows when the skill runs |
| `scripts/validate.sh` | Pre-flight validation (replace with your logic) |
| `scripts/analyze.py` | Analysis helper (replace with your logic) |
| `references/conventions.md` | Org conventions Claude loads for context |
| `references/checklist.md` | Self-verification checklist Claude applies before responding |

## Requirements

- List any CLIs that must be installed (e.g. `gh`, `uv`, `docker`)
- List any env vars that must be set
- Describe any directory context required (e.g. "must run from repo root")

## Example usage

```
/skill-name my-input
```

Expected output:

```
## Result
...

## Details
...

## Next steps
...
```
