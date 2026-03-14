setup() {
  source test/common/setup.sh
  _common_setup
}

# bats file_tags=lib,type:unit

# bench

@test "bench: passes through command when disabled" {
  source home/dot_config/sh/lib/bench.sh
  unset SHELL_BENCH
  run bench echo hello
  assert_success
  assert_output "hello"
}

@test "bench: prints timing when enabled" {
  source home/dot_config/sh/lib/bench.sh
  export SHELL_BENCH=true
  run --separate-stderr bench echo hello
  assert_success
  assert_output "hello"
  assert_stderr_line --regexp "^bench:"
}

@test "bench: uses BENCHFMT label" {
  source home/dot_config/sh/lib/bench.sh
  export SHELL_BENCH=true
  BENCHFMT="custom-label" run --separate-stderr bench echo ok
  assert_success
  assert_stderr_line --regexp "custom-label"
}

@test "bench: preserves command exit code" {
  source home/dot_config/sh/lib/bench.sh
  unset SHELL_BENCH
  run bench false
  assert_failure
}

# export_env

@test "export_env: sources conf and exports variables" {
  local conf="$BATS_TEST_TMPDIR/test.conf"
  printf 'FOO=bar\nBAZ=qux\n' >"$conf"
  source home/dot_config/sh/lib/export.sh
  export_env "$conf"
  [ "$FOO" = bar ]
  [ "$BAZ" = qux ]
}

@test "export_env: missing file is silently skipped" {
  source home/dot_config/sh/lib/export.sh
  run export_env "$BATS_TEST_TMPDIR/nonexistent.conf"
  assert_success
}

@test "export_env: fails with no arguments" {
  source home/dot_config/sh/lib/export.sh
  run export_env
  assert_failure
}

# pathmunge

setup_pathmunge() {
  source home/dot_config/sh/lib/pathmunge.sh
  # Use a controlled PATH so tests are deterministic
  PATH="/usr/bin:/bin"
}

@test "pathmunge: prepends directory by default" {
  setup_pathmunge
  local dir="$BATS_TEST_TMPDIR/prepend"
  mkdir -p "$dir"
  pathmunge "$dir"
  [[ "$PATH" == "$dir:"* ]]
}

@test "pathmunge: appends directory with after" {
  setup_pathmunge
  local dir="$BATS_TEST_TMPDIR/append"
  mkdir -p "$dir"
  pathmunge "$dir" after
  [[ "$PATH" == *":$dir" ]]
}

@test "pathmunge: skips duplicate directory" {
  setup_pathmunge
  local dir="$BATS_TEST_TMPDIR/dup"
  mkdir -p "$dir"
  pathmunge "$dir"
  local first_path="$PATH"
  run pathmunge "$dir"
  assert_failure 2
  [ "$PATH" = "$first_path" ]
}

@test "pathmunge: replace removes and re-prepends existing entry" {
  setup_pathmunge
  local dir="$BATS_TEST_TMPDIR/repl"
  mkdir -p "$dir"
  pathmunge "$dir" after
  [[ "$PATH" == *":$dir" ]]
  pathmunge "$dir" replace
  [[ "$PATH" == "$dir:"* ]]
}

@test "pathmunge: fails on nonexistent directory" {
  setup_pathmunge
  run pathmunge "$BATS_TEST_TMPDIR/missing"
  assert_failure 1
}

@test "pathmunge: fails with no arguments" {
  setup_pathmunge
  run pathmunge
  assert_failure 1
}

@test "pathmunge: fails on empty string" {
  setup_pathmunge
  run pathmunge ""
  assert_failure 1
}
