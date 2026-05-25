# Changelog

## 0.1.0

- Initial release: lefthook-compatible changelog enforcement check.
- Configurable changelog path via `LEFTHOOK_CHANGELOG_FILE` (default: `CHANGELOG.md`).
- Configurable timeout via `LEFTHOOK_CHANGELOG_TOUCHED_TIMEOUT` (default: 30s).
- Pre-commit only — uses `git diff --cached` to check staged files.
