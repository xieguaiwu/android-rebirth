#!/usr/bin/env bash
# Refreshes core/ from the canonical rebirth repo (default:
# ~/Desktop/go-projects/rebirth; override with $1 or $REBIRTH_CORE_SRC).
set -euo pipefail
SRC="${1:-${REBIRTH_CORE_SRC:-$HOME/Desktop/go-projects/rebirth}}"
DEST="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/core"
if [ ! -f "$SRC/go.mod" ]; then
  echo "FAIL: $SRC is not a rebirth checkout (no go.mod)"; exit 1
fi
rm -rf "$DEST/internal" "$DEST/cmd"
cp -a "$SRC/go.mod" "$SRC/internal" "$SRC/cmd" "$DEST/"
git -C "$SRC" rev-parse HEAD > "$DEST/CORE_SOURCE_COMMIT"
echo "core synced from $SRC @ $(git -C "$SRC" rev-parse --short HEAD)"
