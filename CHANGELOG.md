# Changelog

## Unreleased

- Drop `nix-dev-shell-agentic` flake input; build the dev/CI shells inline
  from `flake = false` `-src` sibling inputs. Shrinks `flake.lock` from 59 to
  17 nodes with no change to the `lefthook-changelog-touched` package.

## 0.1.0

- Initial release: lefthook-compatible changelog enforcement check.
- Configurable changelog path via `LEFTHOOK_CHANGELOG_FILE` (default: `CHANGELOG.md`).
- Configurable timeout via `LEFTHOOK_CHANGELOG_TOUCHED_TIMEOUT` (default: 30s).
- Pre-commit only — uses `git diff --cached` to check staged files.
