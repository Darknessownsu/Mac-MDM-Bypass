#!/bin/bash
# Package only explicitly approved read-only toolkit files.
set -eu
umask 077
export PATH=/usr/bin:/bin:/usr/sbin:/sbin
root="$(cd "$(dirname "$0")/.." && pwd)"
[ "$#" -eq 1 ] || { printf '%s\n' 'Usage: bash scripts/package.sh NEW_OUTPUT_DIRECTORY' >&2; exit 2; }
dest="$1"
case "$dest" in /*) ;; *) dest="$PWD/$dest";; esac
# mkdir without -p refuses an existing destination.
mkdir -- "$dest"
mkdir "$dest/bin" "$dest/lib" "$dest/docs"
for f in bin/macadmin lib/core.sh lib/classify.sh lib/report.sh lib/diagnostics.sh lib/menu.sh docs/FOUNDATION.md docs/RECOVERY.md docs/ACCEPTANCE.md LICENSE; do
  [ -f "$root/$f" ] && [ ! -L "$root/$f" ] || { printf 'Invalid source: %s\n' "$f" >&2; exit 1; }
  cp "$root/$f" "$dest/$f"
done
chmod 700 "$dest/bin/macadmin"
printf 'Package staged: %s\n' "$dest"
