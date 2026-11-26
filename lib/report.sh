# Structured, privacy-minimized reports. Values are never included in shared reports.
report_begin() {
  report_first=1
  if [ "$report_format" = json ]; then
    printf '{"schema_version":1,"privacy":"status-only","checks":['
  fi
}
report_result() {
  local label="$1" state="$2" rc="$3" output="$4"
  if [ "$report_format" = json ]; then
    # Labels are fixed internal constants; reject unexpected characters.
    case "$label" in *[!a-zA-Z0-9\ ]*) return 1;; esac
    if [ "$report_first" -eq 0 ]; then printf ','; fi
    report_first=0
    printf '{"check":"%s","status":"%s","exit_code":%s}' "$label" "$state" "$rc"
  elif [ "$report_format" = shared ]; then
    printf '%s: %s (exit %s)\n' "$label" "$state" "$rc"
  elif [ "$state" = completed ]; then
    printf '%s: %s\n' "$label" "$output"
  else
    printf '%s: unavailable (exit %s)\n' "$label" "$rc"
  fi
}
report_end() {
  if [ "$report_format" = json ]; then printf ']}\n'; fi
}
