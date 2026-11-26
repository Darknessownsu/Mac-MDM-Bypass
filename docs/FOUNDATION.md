# MacAdmin Toolkit 2.0 — foundation

Status: alpha.3; experimental, not a production release.

## Scope
Run `bash bin/macadmin --help` for commands. The status, security, enrollment, health and all commands use read-only macOS probes. No automatic privilege escalation; unavailable probes are reported rather than escalated.

## Reporting
Default text output includes raw successful probe output and should be reviewed locally. Add `--shared` for status-only text or `--json` for schema-versioned status-only JSON. Both omit raw command output, including failure messages. These formats report execution outcomes, not compliance or health conclusions. No automatic upload or persistent logging is performed.

## Architecture
- bin/macadmin: argument validation and dispatch
- lib/core.sh: standardized probe results
- lib/report.sh: text and privacy-minimized JSON output
- lib/diagnostics.sh: read-only diagnostic groups
- tests/smoke.sh: CLI contract and unsupported platform tests
- tests/unit.sh: isolated success, failure, privacy and aggregate status tests
- .github/workflows/macadmin-ci.yml: Linux and macOS hosted test matrix
- docs/RECOVERY.md: supported recovery guidance

## Boundaries
No disabling protections, management interference, tracking interference, background persistence, system log deletion or configuration mutation is part of the new toolkit. Historical scripts are not dependencies and must not be executed by the new toolkit. They remain in Git history and the inherited branch tree pending a separate retirement decision.

## Exit codes
0: probes completed or help/version displayed; 1: at least one probe unavailable; 2: invalid usage; 3: unsupported OS.

## Validation
Run `bash tests/smoke.sh` and `bash tests/unit.sh`. Unit tests mock diagnostic dispatch and never invoke actual macOS probes. CI configuration does not by itself establish a passing run or physical Mac compatibility.

## Next steps
Validate actual probes on authorized Intel and Apple silicon Macs, review output semantics, and review legacy executable retirement and visibility before release.
