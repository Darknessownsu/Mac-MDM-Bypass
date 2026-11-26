# MacAdmin Toolkit 2.0 — foundation

Status: alpha.2; experimental, not a production release.

## Scope
Run `bash bin/macadmin --help` for commands. The status, security, enrollment and all commands use read-only macOS probes. No automatic privilege escalation; unavailable probes are reported rather than escalated.

## Architecture
- bin/macadmin: argument validation and dispatch
- lib/core.sh: standardized probe results
- lib/diagnostics.sh: read-only diagnostic groups
- tests/smoke.sh: CLI contract and unsupported platform tests
- tests/unit.sh: isolated success, failure and aggregate status tests
- .github/workflows/macadmin-ci.yml: Linux and macOS hosted test matrix

## Boundaries
No disabling protections, management interference, tracking interference, background persistence, system log deletion or configuration mutation is part of the new toolkit. Historical scripts are not dependencies and must not be executed by the new toolkit. They remain in Git history and the inherited branch tree pending a separate retirement decision. For managed devices, contact the managing organization for authorized release or remediation. For ownership and Activation Lock issues, use Apple's supported ownership verification and recovery channels.

## Exit codes
0: probes completed or help/version displayed; 1: at least one probe unavailable; 2: invalid usage; 3: unsupported OS.
Successful execution does not establish compliance. Review diagnostic output before sharing.

## Validation
Run `bash tests/smoke.sh` and `bash tests/unit.sh`. Unit tests mock diagnostic dispatch and never invoke actual macOS probes. CI configuration does not by itself establish a passing run or physical Mac compatibility.

## Next steps
Add privacy-conscious reporting, validate actual probes on authorized Intel and Apple silicon Macs, and review legacy executable retirement and visibility before release.
