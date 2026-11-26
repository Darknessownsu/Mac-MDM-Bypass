#!/bin/bash
set -eu
root="$(cd "$(dirname "$0")/.." && pwd)"
cli="$root/bin/macadmin"
bash -n "$cli"
bash "$cli" --help | grep -q 'read-only diagnostics'
[ "$(bash "$cli" --version)" = '2.0.0-alpha.4' ]
for arg in invalid status --help --version; do
  rc=0
  bash "$cli" "$arg" extra >/dev/null 2>&1 || rc=$?
  [ "$rc" -eq 2 ]
done
rc=0
bash "$cli" invalid >/dev/null 2>&1 || rc=$?
[ "$rc" -eq 2 ]
if [ "$(uname -s)" != Darwin ]; then
  for fmt in --shared --json; do
    rc=0
    bash "$cli" all "$fmt" >/dev/null 2>&1 || rc=$?
    [ "$rc" -eq 3 ]
  done
fi
printf '%s\n' 'Smoke tests passed.'
