#!/usr/bin/env bash
# scan.sh — automated security pattern scanner
#
# Usage:
#   bash scripts/scan.sh [PATH_OR_GLOB]
#
# Output format (one finding per line):
#   SEVERITY|FILE:LINE|PATTERN|SNIPPET
#
# Exit codes:
#   0 = scan completed (findings may or may not exist)
#   1 = scan error (bad input, missing tools, etc.)

set -euo pipefail

TARGET="${1:-}"
FINDINGS=0

# ── Helpers ──────────────────────────────────────────────────────────────────

emit() {
  local severity="$1" file="$2" line="$3" pattern="$4" snippet="$5"
  echo "${severity}|${file}:${line}|${pattern}|${snippet}"
  FINDINGS=$((FINDINGS + 1))
}

scan_file() {
  local file="$1"
  [[ -f "$file" ]] || return 0

  while IFS= read -r entry; do
    local lineno pattern snippet
    lineno=$(echo "$entry" | cut -d: -f1)
    snippet=$(echo "$entry" | cut -d: -f2-)

    # ── CRITICAL: hardcoded secrets ──────────────────────────────────────
    if echo "$snippet" | grep -qiE \
      '(password|passwd|secret|api_key|apikey|access_token|auth_token)\s*=\s*["'"'"'][^"'"'"']{6,}'; then
      emit "CRITICAL" "$file" "$lineno" "hardcoded-secret" "$snippet"
      continue
    fi

    # ── CRITICAL: private key material ───────────────────────────────────
    if echo "$snippet" | grep -qE \
      'BEGIN (RSA|EC|OPENSSH|DSA) PRIVATE KEY|sk-[a-zA-Z0-9]{40,}'; then
      emit "CRITICAL" "$file" "$lineno" "private-key-material" "$snippet"
      continue
    fi

    # ── HIGH: shell injection vectors ────────────────────────────────────
    if echo "$snippet" | grep -qE \
      'subprocess\.call\(.*shell=True|os\.system\(|eval\(|exec\('; then
      emit "HIGH" "$file" "$lineno" "shell-injection-vector" "$snippet"
      continue
    fi

    # ── HIGH: SQL string concatenation ───────────────────────────────────
    if echo "$snippet" | grep -qiE \
      '(SELECT|INSERT|UPDATE|DELETE|DROP).*\+.*[a-zA-Z_]+|(f"|f'"'"').*SELECT'; then
      emit "HIGH" "$file" "$lineno" "sql-injection-risk" "$snippet"
      continue
    fi

    # ── MEDIUM: error details leaked to response ──────────────────────────
    if echo "$snippet" | grep -qiE \
      'traceback\.print_exc\(\)|str\(e\)|str\(err\)|exception\.message'; then
      emit "MEDIUM" "$file" "$lineno" "error-detail-leak" "$snippet"
      continue
    fi

    # ── MEDIUM: hardcoded localhost/IP (might be leftover debug) ─────────
    if echo "$snippet" | grep -qE \
      '"(http://localhost|http://127\.0\.0\.1|http://0\.0\.0\.0)'; then
      emit "MEDIUM" "$file" "$lineno" "hardcoded-local-url" "$snippet"
      continue
    fi

    # ── LOW: TODO/FIXME with security keywords ────────────────────────────
    if echo "$snippet" | grep -qiE \
      '(TODO|FIXME).*(auth|token|secret|password|permission|bypass)'; then
      emit "LOW" "$file" "$lineno" "security-todo" "$snippet"
      continue
    fi

  done < <(grep -n "" "$file" 2>/dev/null || true)
}

# ── Determine files to scan ──────────────────────────────────────────────────

if [ -n "$TARGET" ]; then
  # Explicit path/glob provided
  mapfile -t FILES < <(find "$TARGET" -type f \
    ! -path '*/.git/*' \
    ! -path '*/node_modules/*' \
    ! -path '*/__pycache__/*' \
    ! -path '*/dist/*' \
    2>/dev/null || true)
else
  # Scan the branch diff
  if ! git rev-parse --git-dir &>/dev/null; then
    echo "ERROR: not inside a git repository" >&2
    exit 1
  fi
  mapfile -t FILES < <(git diff main...HEAD --name-only 2>/dev/null || \
                        git diff HEAD~1...HEAD --name-only 2>/dev/null || true)
fi

if [ "${#FILES[@]}" -eq 0 ]; then
  echo "INFO: no files to scan"
  exit 0
fi

# ── Run scan ─────────────────────────────────────────────────────────────────

echo "SCAN_START|files=${#FILES[@]}"

for file in "${FILES[@]}"; do
  scan_file "$file"
done

echo "SCAN_END|findings=${FINDINGS}"
