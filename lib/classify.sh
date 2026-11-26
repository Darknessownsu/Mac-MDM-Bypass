# Conservative interpretations of successful read-only security probes.
# Unknown text never implies an enabled or disabled control.
classify_result() {
  local label="$1" output="$2"
  case "$label" in
    'System Integrity Protection')
      case "$output" in
        'System Integrity Protection status: enabled.') printf enabled;;
        'System Integrity Protection status: disabled.') printf disabled;;
        *) printf unknown;;
      esac;;
    FileVault)
      case "$output" in
        'FileVault is On.') printf enabled;;
        'FileVault is Off.') printf disabled;;
        *) printf unknown;;
      esac;;
    Gatekeeper)
      case "$output" in
        'assessments enabled') printf enabled;;
        'assessments disabled') printf disabled;;
        *) printf unknown;;
      esac;;
    *) printf not_assessed;;
  esac
}
