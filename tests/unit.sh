#!/bin/bash
set -eu
root="$(cd "$(dirname "$0")/.." && pwd)"
. "$root/lib/report.sh"
. "$root/lib/core.sh"
. "$root/lib/diagnostics.sh"
report_format=text
out=$(probe Test printf '%s' 'hello')
[ "$out" = 'Test: hello' ]
rc=0
out=$(probe Test bash -c 'printf secret >&2; exit 7') || rc=$?
[ "$rc" -eq 1 ]
[ "$out" = 'Test: unavailable (exit 7)' ]
report_format=shared
out=$(probe Test printf '%s' 'private value')
[ "$out" = 'Test: completed (exit 0)' ]
report_format=json
out=$(report_begin; probe Test printf '%s' 'private value'; probe Other bash -c 'exit 7' || :; report_end)
[ "$out" = '{"schema_version":1,"privacy":"status-only","checks":[{"check":"Test","status":"completed","exit_code":0},{"check":"Other","status":"unavailable","exit_code":7}]}' ]
# Mock probe calls; never execute real macOS tools.
probe() { printf '%s\n' "$1"; [ "$1" != FileVault ]; }
rc=0
out=$(diagnose_all) || rc=$?
[ "$rc" -eq 1 ]
printf '%s\n' "$out" | grep -qx Enrollment
printf '%s\n' "$out" | grep -qx Gatekeeper
printf '%s\n' "$out" | grep -qx Uptime
probe() { return 0; }
diagnose_all
printf '%s\n' 'Unit tests passed.'
