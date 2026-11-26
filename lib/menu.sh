# Interactive, read-only interface.
show_menu() {
  local choice action rc
  while :; do
    printf '%s\n' '' 'MacAdmin Toolkit — diagnostics' '1. System status' '2. Security posture' '3. Enrollment status' '4. Health' '5. All checks (shared)' '6. Recovery guidance' '0. Exit'
    printf 'Choice: '
    IFS= read -r choice || return 0
    case "$choice" in
      1) action=status;; 2) action=security;; 3) action=enrollment;;
      4) action=health;; 5) action=all;; 6) action=recovery;;
      0) return 0;; *) printf '%s\n' 'Invalid selection.'; continue;;
    esac
    rc=0
    if [ "$action" = recovery ]; then
      /bin/bash "$root/bin/macadmin" recovery || rc=$?
    else
      /bin/bash "$root/bin/macadmin" "$action" --shared || rc=$?
    fi
    printf 'Result exit code: %s\n' "$rc"
  done
}
