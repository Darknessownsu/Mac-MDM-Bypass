# MacAdmin Toolkit 2.0 — foundation

Status: experimental; not a production release.

## Scope
The new entry point is `bash bin/macadmin`. It reports OS version, architecture, security posture and enrollment status using read-only macOS commands. It does not require elevation by design; unavailable probes are reported rather than escalated.

## Boundaries
No disabling protections, management interference, tracking interference, background persistence, system log deletion or configuration mutation is part of the new toolkit. Historical scripts are not dependencies and must not be executed by the new toolkit. They remain in Git history and in the inherited branch tree pending a separately reviewed retirement decision.

For managed devices, contact the managing organization for authorized release or remediation. For ownership and Activation Lock issues, use Apple's supported ownership verification and recovery channels.

## Exit codes
- 0: requested probes completed, or help/version displayed
- 1: at least one probe unavailable
- 2: invalid usage
- 3: unsupported operating system

A successful probe means the command returned successfully, not that a device is compliant. Output may reveal enrollment information; review before sharing.

## Next steps
Separate probes into modules, add mocked failure tests, verify on supported Intel and Apple silicon macOS versions, and review retirement of legacy executables and repository visibility before release.
