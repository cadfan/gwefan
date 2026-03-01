#!/bin/bash
# Deploy gwefan to griffpi — delegates to griffiths-core.
# Usage:
#   bash deploy.sh                  # full deploy (pre-deploy + build + upload)
#   bash deploy.sh --skip-stats     # skip pre-deploy hook
#   bash deploy.sh --dry-run        # preview only
set -e

cd "$(dirname "$0")"

ARGS=()
for arg in "$@"; do
    case "$arg" in
        --skip-stats) ARGS+=("--skip-pre-deploy") ;;
        *) ARGS+=("$arg") ;;
    esac
done

exec bash tools/griffiths-core/bin/gc-deploy.sh "${ARGS[@]}"
