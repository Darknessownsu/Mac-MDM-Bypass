# Shared diagnostic result handling (Bash 3.2 compatible).
probe() {
  local label="$1" output rc
  shift
  if output=$("$@" 2>&1); then
    printf '%s: %s\n' "$label" "$output"
    return 0
  else
    rc=$?
    printf '%s: unavailable (exit %s)\n' "$label" "$rc"
    return 1
  fi
}
