#!/usr/bin/env bash
# validate.sh — example helper script for a skill
#
# Called by SKILL.md as: bash scripts/validate.sh "$ARGUMENTS"
# Exit 0 = pass, non-zero = fail (Claude reads stderr and reports it)
#
# Replace this script with your actual validation logic.

set -euo pipefail

INPUT="${1:-}"

if [ -z "$INPUT" ]; then
  echo "ERROR: no input provided" >&2
  exit 1
fi

echo "Validating: $INPUT"

# Example checks — replace with your own:
if [ ! -d "$INPUT" ] && [ ! -f "$INPUT" ]; then
  echo "ERROR: '$INPUT' does not exist" >&2
  exit 1
fi

echo "OK: validation passed"
