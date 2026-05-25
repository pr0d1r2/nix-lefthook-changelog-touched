# nix-lefthook-changelog-touched

[![CI](https://github.com/pr0d1r2/nix-lefthook-changelog-touched/actions/workflows/ci.yml/badge.svg)](https://github.com/pr0d1r2/nix-lefthook-changelog-touched/actions/workflows/ci.yml)

> This code is LLM-generated and validated through an automated integration
> process using [lefthook](https://github.com/evilmartians/lefthook) git hooks,
> [bats](https://github.com/bats-core/bats-core) unit tests, and GitHub Actions CI.

Lefthook-compatible changelog enforcement, packaged as a Nix flake.

Fails the pre-commit hook when implementation code is staged without a matching
`CHANGELOG.md` update. Forces changelog entries to travel with the code that
produces them.

## Usage

### Option A: Lefthook remote (recommended)

Add to your `lefthook.yml`:

```yaml
remotes:
  - git_url: https://github.com/pr0d1r2/nix-lefthook-changelog-touched
    ref: main
    configs:
      - lefthook-remote.yml
```

The remote config does **not** set a `glob` — add one in your local
`lefthook.yml` to scope which files trigger the check:

```yaml
pre-commit:
  commands:
    changelog-touched:
      glob: "{src/**/*.py,lib/**/*.rb}"
      run: timeout 30 lefthook-changelog-touched {staged_files}
```

### Option B: Flake input

```nix
inputs.nix-lefthook-changelog-touched = {
  url = "github:pr0d1r2/nix-lefthook-changelog-touched";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

Add to your devShell:

```nix
nix-lefthook-changelog-touched.packages.${pkgs.stdenv.hostPlatform.system}.default
```

### Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `LEFTHOOK_CHANGELOG_TOUCHED_TIMEOUT` | `30` | Timeout in seconds |
| `LEFTHOOK_CHANGELOG_FILE` | `CHANGELOG.md` | Path to changelog file |

## License

MIT
