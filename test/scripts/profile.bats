# shellcheck disable=SC2154

bats_require_minimum_version 1.5.0

setup_file() {
  # shellcheck source=test/common/setup-file.sh
  source test/common/setup-file.sh
  _common_setup_file
}

setup() {
  # shellcheck source=test/common/setup.sh
  source test/common/setup.sh
  _common_setup
  # shellcheck source=test/common/helper.sh
  source test/common/helper.sh
}

# bats file_tags=script,profile

# bats test_tags=type:unit
@test "profile: shows help" {
  run_script ./script/profile --help

  assert_output --partial "Usage: profile [shell]"
  assert_success
}

# bats test_tags=type:unit
@test "profile: shows usage" {
  run_script ./script/profile --usage

  assert_output --partial "shell"
  assert_output --partial "bash"
  assert_output --partial "zsh"
  assert_success
}

# bats test_tags=type:unit
@test "profile: runs bash profile" {
  check_command bash
  run_script ./script/profile bash

  assert_output --partial "total"
  assert_output --partial "pct"
  assert_output --partial "command"
  assert_success
}

# bats test_tags=type:unit
@test "profile: handles broken pipe gracefully" {
  check_command bash
  run bash -c 'set -o pipefail; ./script/profile bash | head -1'

  assert_output --partial "total"
}

# bats test_tags=type:unit
@test "profile: rejects invalid shell" {
  run_script ./script/profile nonexistent

  assert_stderr --partial "invalid shell"
  assert_failure 2
}

# bats test_tags=type:unit
@test "profile: uses default shell from SHELL" {
  check_command bash
  export SHELL="/bin/bash"
  run_script ./script/profile

  assert_output --partial "total"
  assert_success
}

# bats test_tags=type:unit
@test "profile: produces valid output format" {
  check_command bash
  run_script ./script/profile bash

  # Check for table header
  assert_line --regexp "total.*pct.*calls.*command"

  # Check for data rows with timing information
  assert_line --partial "ms"
  assert_line --partial "%"
  assert_line --partial ")"

  assert_success
}

# bats test_tags=type:unit
@test "profile: handles missing sheldon gracefully" {
  check_command bash
  stub sheldon "exit 127"
  run_script ./script/profile bash
  unstub sheldon 2>/dev/null || true

  assert_output --partial "total"
  assert_success
}

# bats test_tags=type:unit
@test "profile: bounds and surfaces init stderr without flooding the trace" {
  check_command bash
  local fakehome="$BATS_TEST_TMPDIR/fakehome"
  mkdir -p "$fakehome"
  # Repro: a "|" line in init stderr must not be read as a regex and dump the trace
  cat >"$fakehome/.bashrc" <<'RC'
for _ in $(seq 1 300); do :; done
printf 'WARN failed to parse manifest:\n  |\nmissing field short\n' >&2
RC

  HOME="$fakehome" run_script ./script/profile bash

  assert_failure
  assert_stderr --partial "missing field short"
  [ "${#stderr_lines[@]}" -lt 60 ] || fail "init stderr not bounded: ${#stderr_lines[@]} lines"
}
