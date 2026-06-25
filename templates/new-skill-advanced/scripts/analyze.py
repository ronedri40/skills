#!/usr/bin/env python3
"""analyze.py — example analysis helper script for a skill.

Called by SKILL.md as: python3 scripts/analyze.py "$ARGUMENTS"
Prints a structured report to stdout that Claude can interpret.
Exit 0 = success, non-zero = error.
"""

import sys


def main() -> int:
    target = sys.argv[1] if len(sys.argv) > 1 else ""

    if not target:
        print("ERROR: no target provided", file=sys.stderr)
        return 1

    # Replace with your actual analysis logic.
    print(f"Analyzing: {target}")
    print("---")
    print("findings: []")
    print("summary: no issues found")
    return 0


if __name__ == "__main__":
    sys.exit(main())
