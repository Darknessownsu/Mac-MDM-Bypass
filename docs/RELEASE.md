# 2.0.0-rc.1 candidate

Development candidate only. No release or merge is authorized by this document.

Use `bash bin/macadmin menu` on an authorized Mac, or individual commands with `--shared` or `--json`. Recovery displays guidance only. No automatic privilege escalation or system mutation.

Run the tests listed in FOUNDATION.md. To stage an isolated package locally, run `bash scripts/package.sh /path/to/new-directory`. The allowlist excludes historical scripts, Git metadata, CI and test files. Never distribute a repository archive as a toolkit package.

Acceptance requires physical device evidence, CI evidence, visibility approval and license review. See ACCEPTANCE.md.
