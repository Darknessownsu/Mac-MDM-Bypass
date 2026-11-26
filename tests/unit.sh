#!/bin/bash
set -eu
root="$(cd "$(dirname "$0")/.." && pwd)"
. "$root/lib/core.sh"
. "$root/lib/diagnostics.sh"
out=$(probe Test printf '%s' 'hello')
[ "$out" = 'Test: hello' ]
rc=0
out=$(probe Test bash -c 'printf secret >&2; exit 7') || rc=$?
[ "$rc" -eq 1 ]
[ "$out" = 'Test: unavailable (exit 7)' ]
# Mock the probe function, never invoke real macOS tools here.
probe() { printf '%s\n' "$1"; [ "$1" != FileVault ]; }
rc=0
out=$(diagnose_all) || rc=$?
[ "$rc" -eq 1 ]
printf '%s\n' "$out" | grep -qx Enrollment
printf '%s\n' "$out" | grep -qx Gatekeeper
probe() { return 0; }
diagnose_all
printf '%s\n' 'Unit tests passed.'
