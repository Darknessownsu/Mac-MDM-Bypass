# MacAdmin Toolkit 2.0 — foundation

Status: 2.0.0-rc.1; experimental, not a production release.

## Scope
Run `bash bin/macadmin --help` for commands. The status, security, enrollment, health and all commands use read-only macOS probes. No automatic privilege escalation; unavailable probes are reported rather than escalated.

The menu command offers interactive shared diagnostics; recovery displays supported guidance without changing settings.

## Reporting
Default text output includes raw successful probe output and should be reviewed locally. Add `--shared` for status-only text or `--json` for schema-versioned status-only JSON. Both omit raw command output, including failure messages. These formats report execution outcomes and conservative classifications for recognized SIP, FileVault and Gatekeeper responses. Unknown or transitional responses remain unknown; other checks are not assessed. No classification establishes compliance. JSON schema version 2 adds classification. No automatic upload or persistent logging is performed.

## Architecture
- bin/macadmin: argument validation and dispatch
- lib/classify.sh: exact-match security classification
- lib/menu.sh: interactive menu
- scripts/package.sh: explicit allowlist packaging
- lib/core.sh: standardized probe results
- lib/report.sh: text and privacy-minimized JSON output
- lib/diagnostics.sh: read-only diagnostic groups
- tests/smoke.sh: CLI contract and unsupported platform tests
- tests/unit.sh: isolated success, failure, privacy and aggregate status tests
- .github/workflows/macadmin-ci.yml: Linux and macOS hosted test matrix
- docs/ACCEPTANCE.md: release gates and compatibility record
- docs/RECOVERY.md: supported recovery guidance

## Boundaries
No disabling protections, management interference, tracking interference, background persistence, system log deletion or configuration mutation is part of the new toolkit. Historical scripts are not dependencies and must not be executed by the new toolkit. They remain in Git history and the inherited branch tree pending a separate retirement decision.

## Exit codes
0: probes completed or help/version displayed; 1: at least one probe unavailable; 2: invalid usage; 3: unsupported OS.

## Validation
Run `bash tests/smoke.sh` and `bash tests/unit.sh` and `bash tests/classification.sh` and `bash tests/package.sh`. Unit tests mock diagnostic dispatch and never invoke actual macOS probes. CI configuration does not by itself establish a passing run or physical Mac compatibility.

## Remaining release gates
Validate actual probes on authorized Intel and Apple silicon Macs, review output semantics, and review legacy executable retirement and visibility before release.
