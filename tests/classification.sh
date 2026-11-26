#!/bin/bash
set -eu
root="$(cd "$(dirname "$0")/.." && pwd)"
. "$root/lib/classify.sh"
[ "$(classify_result 'System Integrity Protection' 'System Integrity Protection status: enabled.')" = enabled ]
[ "$(classify_result 'System Integrity Protection' 'System Integrity Protection status: disabled.')" = disabled ]
[ "$(classify_result FileVault 'FileVault is On.')" = enabled ]
[ "$(classify_result FileVault 'FileVault is Off.')" = disabled ]
[ "$(classify_result FileVault 'Encryption in progress')" = unknown ]
[ "$(classify_result Gatekeeper 'assessments enabled')" = enabled ]
[ "$(classify_result Gatekeeper 'assessments disabled')" = disabled ]
[ "$(classify_result Gatekeeper '')" = unknown ]
[ "$(classify_result Enrollment 'private organization')" = not_assessed ]
[ "$(classify_result FileVault 'FileVault is On. unexpected')" = unknown ]
printf '%s\n' 'Classification tests passed.'
