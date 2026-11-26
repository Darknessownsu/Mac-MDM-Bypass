#!/bin/bash
set -eu
root="$(cd "$(dirname "$0")/.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
bash "$root/scripts/package.sh" "$tmp/package"
actual="$(cd "$tmp/package" && find . -type f | LC_ALL=C sort)"
expected='./LICENSE
./bin/macadmin
./docs/ACCEPTANCE.md
./docs/FOUNDATION.md
./docs/RECOVERY.md
./lib/classify.sh
./lib/core.sh
./lib/diagnostics.sh
./lib/menu.sh
./lib/report.sh'
[ "$actual" = "$expected" ]
[ "$(bash "$tmp/package/bin/macadmin" --version)" = '2.0.0-rc.1' ]
if bash "$root/scripts/package.sh" "$tmp/package" >/dev/null 2>&1; then exit 1; fi
printf '%s\n' 'Package tests passed.'
