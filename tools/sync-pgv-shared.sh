#!/bin/bash
# Copies the files that the pgv skills share from shared/pgv/ into each skill,
# so that every skill folder is complete by itself.
# With --check it changes nothing and fails when a copy differs from its source.
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
check=0
[ "${1:-}" = "--check" ] && check=1

copy() {
  local src="$root/shared/pgv/$1" dst="$root/skills/$2/references/$1"
  if [ "$check" = 1 ]; then
    cmp -s "$src" "$dst" || { echo "differs: skills/$2/references/$1" >&2; exit 1; }
  else
    mkdir -p "$(dirname "$dst")"
    cp "$src" "$dst"
  fi
}

for skill in pgv-setup pgv-build pgv-integrate; do
  copy records.md "$skill"
  copy model-routing.md "$skill"
  copy execution/claude-code.md "$skill"
  copy execution/codex.md "$skill"
  copy execution/antigravity.md "$skill"
  copy execution/t3-code.md "$skill"
done
[ "$check" = 1 ] && echo "shared files match" || echo "shared files copied"
