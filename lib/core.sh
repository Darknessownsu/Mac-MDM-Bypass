# Shared diagnostic result handling (Bash 3.2 compatible).
probe() {
  local label="$1" output rc
  shift
  if output=$("$@" 2>&1); then
    report_result "$label" completed 0 "$output"
  else
    rc=$?
    report_result "$label" unavailable "$rc" ''
    return 1
  fi
}
