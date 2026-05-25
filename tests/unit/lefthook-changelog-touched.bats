#!/usr/bin/env bats

setup() {
    load "${BATS_LIB_PATH}/bats-support/load.bash"
    load "${BATS_LIB_PATH}/bats-assert/load.bash"

    TMP="$BATS_TEST_TMPDIR/repo"
    mkdir -p "$TMP"
    git -C "$TMP" init -q
    git -C "$TMP" config user.email "test@test.com"
    git -C "$TMP" config user.name "Test"

    touch "$TMP/CHANGELOG.md"
    git -C "$TMP" add CHANGELOG.md
    git -C "$TMP" commit -q -m "init"
}

@test "no args exits 0" {
    cd "$TMP"
    run lefthook-changelog-touched
    assert_success
}

@test "passes when CHANGELOG.md is staged with impl code" {
    cd "$TMP"
    echo "change" > "$TMP/script.sh"
    echo "## Unreleased" >> "$TMP/CHANGELOG.md"
    git -C "$TMP" add script.sh CHANGELOG.md
    run lefthook-changelog-touched script.sh
    assert_success
}

@test "fails when impl code staged without CHANGELOG.md" {
    cd "$TMP"
    echo "change" > "$TMP/script.sh"
    git -C "$TMP" add script.sh
    run lefthook-changelog-touched script.sh
    assert_failure
    assert_output --partial "impl code staged without CHANGELOG.md"
    assert_output --partial "script.sh"
}

@test "lists all offending files in output" {
    cd "$TMP"
    echo "a" > "$TMP/one.sh"
    echo "b" > "$TMP/two.nix"
    git -C "$TMP" add one.sh two.nix
    run lefthook-changelog-touched one.sh two.nix
    assert_failure
    assert_output --partial "one.sh"
    assert_output --partial "two.nix"
}

@test "respects LEFTHOOK_CHANGELOG_FILE override" {
    cd "$TMP"
    touch "$TMP/CHANGES.txt"
    git -C "$TMP" add CHANGES.txt
    echo "change" > "$TMP/script.sh"
    git -C "$TMP" add script.sh CHANGES.txt
    LEFTHOOK_CHANGELOG_FILE=CHANGES.txt run lefthook-changelog-touched script.sh
    assert_success
}

@test "fails with custom changelog name when not staged" {
    cd "$TMP"
    echo "change" > "$TMP/script.sh"
    git -C "$TMP" add script.sh
    LEFTHOOK_CHANGELOG_FILE=CHANGES.txt run lefthook-changelog-touched script.sh
    assert_failure
    assert_output --partial "CHANGES.txt"
}
