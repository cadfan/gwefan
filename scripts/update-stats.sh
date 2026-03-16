#!/bin/bash
# Generate data/islet.json from the local islet repository.
# Called by deploy.sh before hugo --minify.
set -e

# Load ISLET_REPO from deploy.conf if available, fall back to env or default
SCRIPT_DIR="$(dirname "$0")"
if [ -f "$SCRIPT_DIR/../deploy.conf" ]; then
  _islet_repo=$(grep '^islet_repo=' "$SCRIPT_DIR/../deploy.conf" 2>/dev/null | cut -d= -f2-)
  [ -n "$_islet_repo" ] && ISLET_REPO="${ISLET_REPO:-$(eval echo "$_islet_repo")}"
fi
ISLET_REPO="${ISLET_REPO:-$HOME/islet}"
OUTFILE="$(dirname "$0")/../data/islet.json"

# Hardcoded (rarely change)
LANGUAGE="Python 3.13.5"
RUNTIME="Raspberry Pi 5B, systemd, SQLite"

if [ ! -d "$ISLET_REPO" ]; then
  echo "Warning: islet repo not found at $ISLET_REPO — skipping stats update" >&2
  exit 0
fi

# Python SLOC: non-blank, non-comment lines in islet/**/*.py
python_sloc=$(find "$ISLET_REPO/islet" -name '*.py' -print0 \
  | xargs -0 grep -v '^\s*$' | grep -v '^\s*#' | wc -l)

# Swift SLOC: non-blank, non-comment lines in ios/**/*.swift
swift_sloc=0
if [ -d "$ISLET_REPO/ios" ]; then
  swift_sloc=$(find "$ISLET_REPO/ios" -name '*.swift' -print0 \
    | xargs -0 grep -v '^\s*$' | grep -v '^\s*//' | wc -l)
fi

# Combined SLOC
source_sloc=$((python_sloc + swift_sloc))

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
  status="$progress_phase"
else
  status="In development"
fi

# All commits — use tab separator then build JSON safely
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
done < <(git -C "$ISLET_REPO" log --format="%ad%x09%h%x09%s" --date=short)
commits_json+="]"

# Write JSON
cat > "$OUTFILE" <<ENDJSON
{
  "sloc": ${source_sloc},
  "python_sloc": ${python_sloc},
  "swift_sloc": ${swift_sloc},
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

echo "Updated $(basename "$OUTFILE"): ${python_sloc} Python + ${swift_sloc} Swift SLOC, ${test_count} tests, ${total_commits} commits"
