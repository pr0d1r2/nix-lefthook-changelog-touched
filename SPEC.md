# SPEC — nix-lefthook-changelog-touched

## §D — Description

A Nix-flake-packaged lefthook pre-commit hook that enforces changelog discipline by failing the commit when implementation files are staged without a corresponding update to `CHANGELOG.md` (or a configurable alternative). It targets Nix-based development teams who use lefthook for git hooks and want to guarantee that every code change ships with a human-written changelog entry. The tool is consumed either as a lefthook remote config or as a flake input added to a project's devShell.

## §V — Invariants

1. The script MUST exit 0 when invoked with zero arguments (no files to check).
2. The script MUST exit 0 when the changelog file appears in `git diff --cached --name-only`, regardless of the implementation files passed.
3. The script MUST exit 1 and print a diagnostic to stderr listing every offending file when implementation files are staged without the changelog.
4. The changelog filename MUST be overridable via `LEFTHOOK_CHANGELOG_FILE`; default is `CHANGELOG.md`.
5. The timeout MUST be overridable via `LEFTHOOK_CHANGELOG_TOUCHED_TIMEOUT`; default is `30` seconds.
6. The Nix flake MUST build on all four supported systems: `aarch64-darwin`, `x86_64-darwin`, `x86_64-linux`, `aarch64-linux`.
7. The flake package MUST declare `git` as a runtime input (the script calls `git diff`).
8. All unit tests MUST pass under `bats` with `bats-support` and `bats-assert` libraries.
9. CI MUST run on Linux for every push and PR to `main`; macOS runs on push and workflow_dispatch only.
10. The script MUST NOT include a shebang or `set` flags — `writeShellApplication` provides both.
11. YAML files MUST pass `yamllint` (truthy key-check disabled, line-length disabled).
12. Markdown files MUST pass `markdownlint` (MD013/line-length disabled).
13. EditorConfig enforces: UTF-8, LF line endings, final newline, no trailing whitespace, 2-space indent.

## §I — Interfaces

### CLI

```
lefthook-changelog-touched [FILE ...]
```

- **Arguments**: Zero or more file paths (typically `{staged_files}` expanded by lefthook).
- **Exit 0**: No arguments given, or the changelog file is present in `git diff --cached --name-only`.
- **Exit 1**: At least one file argument and changelog is not staged. Diagnostic printed to stderr.

### Environment Variables

| Variable | Type | Default | Description |
|---|---|---|---|
| `LEFTHOOK_CHANGELOG_FILE` | `string` | `CHANGELOG.md` | Path to the changelog file checked in the staging area |
| `LEFTHOOK_CHANGELOG_TOUCHED_TIMEOUT` | `integer` | `30` | Timeout in seconds wrapping the command in `lefthook-remote.yml` |

### Nix Flake Outputs

| Output | Description |
|---|---|
| `packages.<system>.default` | `writeShellApplication` wrapping `lefthook-changelog-touched.sh` with `git` in PATH |
| `devShells.<system>.default` | Full dev shell with lefthook, bats, all remote linter wrappers, and `BATS_LIB_PATH` |
| `devShells.<system>.ci` | CI-oriented shell (same packages, no interactive shellHook) |

### Lefthook Config (`lefthook-remote.yml`)

```yaml
pre-commit:
  commands:
    changelog-touched:
      run: timeout ${LEFTHOOK_CHANGELOG_TOUCHED_TIMEOUT:-30} lefthook-changelog-touched {staged_files}
```

Consumers add a `glob` in their local `lefthook.yml` to scope which files trigger the check.

### File Size Limits (`config/lefthook/file_size_limits.yml`)

| Extension | Limit (bytes) |
|---|---|
| (default) | 4096 |
| `.lock` | 65536 |
| `.nix` | 10240 |
| `.bats` | 4096 |
| `.yml` | 4096 |

## §T — Tasks

| status | id | goal |
|---|---|---|
| `.` | T1 | Add test for filenames containing spaces to verify quoting in the `for f in "$@"` loop |
| `.` | T2 | Add test verifying the error message includes the "Fix:" hint text |
| `.` | T3 | Add integration test exercising the full lefthook pre-commit flow end-to-end |
| `.` | T4 | Align `actions/checkout` version across workflows (`ci.yml` uses v6, `update-pins.yml` uses v4) |
| `.` | T5 | Add `nix flake check` step to CI (currently delegated entirely to `nix-lefthook-ci-action`) |
| `.` | T6 | Add `--help` flag that prints usage and exits 0 |
| `.` | T7 | Document dev shell setup and how to run tests locally in README |
| `.` | T8 | Add test for a changelog file in a subdirectory (`LEFTHOOK_CHANGELOG_FILE=docs/CHANGES.md`) |
| `.` | T9 | Tag and release v0.2.0 once the Unreleased section in CHANGELOG.md is finalized |
| `.` | T10 | Add a `glob` example for common language patterns (e.g., Nix, shell, Python) to README |

## §B — Bugs / Known Issues

1. **`actions/checkout` version skew**: `ci.yml` uses `actions/checkout@v6` while `update-pins.yml` uses `actions/checkout@v4`. This is not a functional bug but risks divergent checkout behavior and should be aligned.

2. **No glob in `lefthook-remote.yml`**: The remote config does not set a `glob`, so if a consumer forgets to add one locally, *every* staged file triggers the check — including documentation-only changes that arguably should not require a changelog entry. The README documents this but there is no runtime warning.

3. **Timeout binary assumed available**: The `lefthook-remote.yml` wraps the command in `timeout` (from coreutils), but this is only guaranteed when the Nix devShell is active. Non-Nix consumers who install the script manually may lack `timeout` on macOS (BSD coreutils) without GNU coreutils.

4. **No support for multiple changelog files**: Projects with per-package changelogs (monorepo pattern) cannot use a single `LEFTHOOK_CHANGELOG_FILE` value. The tool only checks one file.

5. **Silent pass on unstaged-only changes**: If a developer modifies files but stages nothing (`git diff --cached` is empty), all passed file paths will trigger a false failure since the changelog won't appear in the empty staged list. In practice lefthook's `{staged_files}` expansion prevents this, but invoking the script manually with args and no staged files produces a misleading error.
