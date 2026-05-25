# shellcheck shell=bash
# Lefthook-compatible changelog enforcement.
# Fails when implementation code is staged without a matching CHANGELOG update.
# Usage: lefthook-changelog-touched file1.sh [file2.nix ...]
# NOTE: sourced by writeShellApplication — no shebang or set needed.

if [ $# -eq 0 ]; then
    exit 0
fi

CHANGELOG="${LEFTHOOK_CHANGELOG_FILE:-CHANGELOG.md}"

staged="$(git diff --cached --name-only)"
if grep -qxF "$CHANGELOG" <<<"$staged"; then
    exit 0
fi

{
    echo "check-changelog-touched: impl code staged without $CHANGELOG:"
    for f in "$@"; do
        printf '  %s\n' "$f"
    done
    echo
    echo "Fix: append a line to the '## Unreleased' section of"
    echo "     $CHANGELOG and stage it with this commit."
} >&2
exit 1
