#!/bin/bash
# Generate data/islet.json from the local islet repository.
# Called by deploy.sh before hugo --minify.
set -e

ISLET_REPO="${ISLET_REPO:-$HOME/Documents/GitHub/islet}"
OUTFILE="$(dirname "$0")/../data/islet.json"

# Hardcoded (rarely change)
LANGUAGE="Python 3.13.5"
RUNTIME="Raspberry Pi 5B, systemd, SQLite"

if [ ! -d "$ISLET_REPO" ]; then
  echo "Warning: islet repo not found at $ISLET_REPO — skipping stats update" >&2
  exit 0
fi

# Source SLOC: non-blank, non-comment lines in islet/**/*.py
source_sloc=$(find "$ISLET_REPO/islet" -name '*.py' -print0 \
  | xargs -0 grep -v '^\s*$' | grep -v '^\s*#' | wc -l)

# Test SLOC: non-blank, non-comment lines in tests/**/*.py
test_sloc=$(find "$ISLET_REPO/tests" -name '*.py' -print0 \
  | xargs -0 grep -v '^\s*$' | grep -v '^\s*#' | wc -l)

# Test count: def test_ across tests/
test_count=$(grep -r "def test_" "$ISLET_REPO/tests/" --include='*.py' | wc -l)

# Doc lines: total lines in *.md files in repo root
doc_lines=$(cat "$ISLET_REPO"/*.md 2>/dev/null | wc -l)

# Total commits
total_commits=$(git -C "$ISLET_REPO" rev-list --count HEAD)

# Status: parse from PROGRESS_REPORT.md "**Phase:**" line, fall back to README
progress_phase=$(grep -m1 '^\*\*Phase:\*\*' "$ISLET_REPO/PROGRESS_REPORT.md" 2>/dev/null \
  | sed 's/\*\*Phase:\*\* //')
if [ -n "$progress_phase" ]; then
  status="Phase $progress_phase"
else
  status="In development"
fi

# Recent commits (last 20) — use tab separator then build JSON safely
commits_json="["
first=true
while IFS=$'\t' read -r cdate chash cmsg; do
  # Escape backslashes and double quotes in commit message
  cmsg=$(echo "$cmsg" | sed 's/\\/\\\\/g; s/"/\\"/g')
  if [ "$first" = true ]; then
    first=false
  else
    commits_json+=","
  fi
  commits_json+="{\"date\":\"${cdate}\",\"hash\":\"${chash}\",\"message\":\"${cmsg}\"}"
done < <(git -C "$ISLET_REPO" log -20 --format="%ad%x09%h%x09%s" --date=short)
commits_json+="]"

# Write JSON
cat > "$OUTFILE" <<ENDJSON
{
  "sloc": ${source_sloc},
  "test_sloc": ${test_sloc},
  "test_count": ${test_count},
  "doc_lines": ${doc_lines},
  "total_commits": ${total_commits},
  "language": "${LANGUAGE}",
  "runtime": "${RUNTIME}",
  "status": "${status}",
  "commits": ${commits_json}
}
ENDJSON

echo "Updated $(basename "$OUTFILE"): ${source_sloc} SLOC, ${test_count} tests, ${total_commits} commits"
