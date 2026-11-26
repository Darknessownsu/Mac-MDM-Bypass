# Release acceptance gates

No public or production release is approved. All gates below require recorded evidence.

- [ ] Linux isolated tests pass on the exact candidate revision.
- [ ] macOS isolated tests pass on the exact candidate revision.
- [ ] Authorized Intel and Apple silicon devices tested without elevation.
- [ ] Each read-only probe verified against the system's displayed settings.
- [ ] Unknown and transitional security states are not misclassified.
- [ ] Shared and JSON output contains no raw diagnostic values.
- [ ] No system changes, service installs, persistent logs, or automatic network uploads observed.
- [ ] Legacy executables excluded from any distributed package.
- [ ] Repository visibility and release distribution reviewed and approved.
- [ ] Documentation and license reviewed.

## Manual compatibility record
Record candidate commit, OS version, architecture, command, observed exit code, and redacted findings. Do not include serial numbers, account names, enrollment organization, or raw logs. Compare status with trusted macOS settings. Do not change security controls merely to produce test cases; use synthetic fixtures instead.

## Failure policy
An unavailable probe or unknown classification is not evidence of compliance. Stop release on unexplained discrepancies. Do not use historical scripts for validation.
