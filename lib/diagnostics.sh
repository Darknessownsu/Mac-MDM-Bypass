# Read-only macOS probes. No privilege escalation.
diagnose_status() {
  local rc=0
  probe 'macOS' /usr/bin/sw_vers -productVersion || rc=1
  probe 'Architecture' /usr/bin/uname -m || rc=1
  return "$rc"
}
diagnose_security() {
  local rc=0
  probe 'System Integrity Protection' /usr/bin/csrutil status || rc=1
  probe 'FileVault' /usr/bin/fdesetup status || rc=1
  probe 'Gatekeeper' /usr/sbin/spctl --status || rc=1
  return "$rc"
}
diagnose_enrollment() {
  probe 'Enrollment' /usr/bin/profiles status -type enrollment
}
diagnose_health() {
  local rc=0
  probe 'Root volume capacity' /bin/df -k / || rc=1
  probe 'Uptime' /usr/bin/uptime || rc=1
  return "$rc"
}
diagnose_all() {
  local rc=0
  diagnose_status || rc=1
  diagnose_security || rc=1
  diagnose_enrollment || rc=1
  diagnose_health || rc=1
  return "$rc"
}
