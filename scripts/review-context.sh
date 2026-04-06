#!/usr/bin/env bash
# Print a standard bundle for the Code Review Agent: main...HEAD (three-dot).
set -euo pipefail
cd "$(dirname "$0")/.."

if ! git rev-parse --git-dir >/dev/null 2>&1; then
  echo "Error: not a git repository." >&2
  exit 1
fi

# Prefer origin/main if local main is missing
BASE="main"
if ! git rev-parse --verify "$BASE" >/dev/null 2>&1; then
  if git rev-parse --verify "origin/main" >/dev/null 2>&1; then
    BASE="origin/main"
  else
    echo "Error: no main or origin/main found." >&2
    exit 1
  fi
fi

echo "=== Code review context: ${BASE}...HEAD ==="
echo ""
echo "--- Commits (${BASE}..HEAD) ---"
git log "${BASE}..HEAD" --oneline 2>/dev/null || true
echo ""
echo "--- Changed files ---"
git diff --name-only "${BASE}...HEAD" 2>/dev/null || true
echo ""
echo "--- Diff stat ---"
git diff --stat "${BASE}...HEAD" 2>/dev/null || true
echo ""
echo "--- Full diff (apply in agent or paste excerpts) ---"
git diff "${BASE}...HEAD" 2>/dev/null || true
