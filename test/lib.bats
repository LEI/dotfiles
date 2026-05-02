setup() {
  # shellcheck source=test/common/setup.sh
  source test/common/setup.sh
  _common_setup
}

# bats file_tags=lib,type:unit

# bench

@test "bench: passes through command when disabled" {
  # shellcheck source=home/dot_local/lib/bash/bench.sh
  source home/dot_local/lib/bash/bench.sh
  unset SHELL_BENCH
  run bench test-label echo hello
  assert_success
  assert_output "hello"
}

@test "bench: prints timing when enabled" {
  # shellcheck source=home/dot_local/lib/bash/bench.sh
  source home/dot_local/lib/bash/bench.sh
  # shellcheck disable=SC2030,SC2031
  export SHELL_BENCH=true
  run --separate-stderr bench test-label echo hello
  assert_success
  assert_output "hello"
  assert_stderr_line --regexp "^bench: test-label:"
}

@test "bench: uses first arg as label" {
  # shellcheck source=home/dot_local/lib/bash/bench.sh
  source home/dot_local/lib/bash/bench.sh
  # shellcheck disable=SC2030,SC2031
  export SHELL_BENCH=true
  run --separate-stderr bench custom-label echo ok
  assert_success
  assert_stderr_line --regexp "custom-label"
}

@test "bench: preserves command exit code" {
  # shellcheck source=home/dot_local/lib/bash/bench.sh
  source home/dot_local/lib/bash/bench.sh
  unset SHELL_BENCH
  run bench test-label false
  assert_failure
}

# export_env

@test "export_env: sources conf and exports variables" {
  local conf="$BATS_TEST_TMPDIR/test.conf"
  printf 'FOO=bar\nBAZ=qux\n' >"$conf"
  # shellcheck source=home/dot_local/lib/sh/export.sh
  source home/dot_local/lib/sh/export.sh
  export_env "$conf"
  assert_equal "bar" "$FOO"
  assert_equal "qux" "$BAZ"
}

@test "export_env: missing file is silently skipped" {
  # shellcheck source=home/dot_local/lib/sh/export.sh
  source home/dot_local/lib/sh/export.sh
  run export_env "$BATS_TEST_TMPDIR/nonexistent.conf"
  assert_success
  refute_output
}

@test "export_env: succeeds with no arguments" {
  # shellcheck source=home/dot_local/lib/sh/export.sh
  source home/dot_local/lib/sh/export.sh
  run export_env
  assert_success
}

# pathmunge

setup_pathmunge() {
  # shellcheck source=home/dot_local/lib/bash/pathmunge.sh
  source home/dot_local/lib/bash/pathmunge.sh
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
  assert_success
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

# results

setup_report() {
  # shellcheck source=home/dot_local/lib/bash/report.sh
  source home/dot_local/lib/bash/report.sh
}

@test "report_human: empty input is silent and returns success" {
  setup_report
  report_collect ""
  run --separate-stderr report_human label 1
  assert_success
  refute_output
  refute_stderr
}

@test "report_human: default verbosity prints FAIL lines and summary" {
  setup_report
  report_collect "PASS a
FAIL b
SKIP c # reason"
  run --separate-stderr report_human v 1
  assert_failure
  assert_output "FAIL b"
  assert_stderr_line "v: 1 passed, 1 failed, 1 skipped"
}

@test "report_human: verbosity 2 prints all PASS/FAIL/SKIP" {
  setup_report
  report_collect "PASS a
FAIL b"
  run --separate-stderr report_human v 2
  assert_failure
  assert_line "PASS a"
  assert_line "FAIL b"
}

@test "report_human: verbosity 0 suppresses summary" {
  setup_report
  report_collect "PASS a"
  run --separate-stderr report_human v 0
  assert_success
  refute_stderr
}

@test "report_tap: emits TAP 14 plan and ok/not ok" {
  setup_report
  report_collect "PASS a
FAIL b
SKIP c # no schema"
  run report_tap label
  assert_failure
  assert_line --index 0 "TAP version 14"
  assert_line --index 1 "1..3"
  assert_line "ok 1 - a"
  assert_line "not ok 2 - b"
  assert_line "ok 3 - c # SKIP no schema"
}

@test "report_tap: SKIP without reason emits bare # SKIP" {
  setup_report
  report_collect "SKIP only"
  run report_tap l
  assert_success
  assert_line "ok 1 - only # SKIP"
}

@test "report_tap: diagnostic lines after FAIL emit as # comments" {
  setup_report
  report_collect "FAIL bad
  schema mismatch
  on line 5"
  run report_tap l
  assert_failure
  assert_line "not ok 1 - bad"
  assert_line "#   schema mismatch"
  assert_line "#   on line 5"
}

# parallel

setup_parallel() {
  # shellcheck source=home/dot_local/lib/bash/parallel.sh
  source home/dot_local/lib/bash/parallel.sh
}

@test "clamp: clamps value to min and max bounds" {
  setup_parallel
  assert_equal "$(clamp 5 1 10)" "5"
  assert_equal "$(clamp 0 1 10)" "1"
  assert_equal "$(clamp 20 1 10)" "10"
}

@test "clamp: uses defaults when bounds not provided" {
  setup_parallel
  assert_equal "$(clamp 50)" "32"
  assert_equal "$(clamp 100 1)" "32"
  assert_equal "$(clamp 5)" "5"
}

@test "get_cpu_count: respects NPROC override and validates input" {
  setup_parallel
  assert_equal "$(NPROC=16 get_cpu_count)" "16"
  assert_equal "$(NPROC=0 get_cpu_count)" "1"
  assert_equal "$(NPROC=-5 get_cpu_count)" "1"
  assert_equal "$(NPROC=abc get_cpu_count)" "1"
  unset NPROC
  run get_cpu_count
  assert_success
  [[ "$output" =~ ^[1-9][0-9]*$ ]]
}

@test "default_jobs: caps at 32 and handles edge cases" {
  setup_parallel
  assert_equal "$(NPROC=100 default_jobs)" "32"
  assert_equal "$(NPROC=42 default_jobs)" "32"
  assert_equal "$(NPROC=0 default_jobs)" "1"
  unset NPROC
  run default_jobs
  assert_success
  [[ "$output" =~ ^[1-9][0-9]*$ ]]
  [ "$output" -le 32 ]
}

# validate

setup_validate() {
  # shellcheck source=home/dot_local/lib/bash/validate.sh
  source home/dot_local/lib/bash/validate.sh
}

@test "usage_spec: extracts #USAGE lines stripped of prefix" {
  setup_validate
  local lib="$PWD/home/dot_local/lib/bash/validate.sh"
  local file="$BATS_TEST_TMPDIR/sample.sh"
  cat >"$file" <<'EOF'
#USAGE flag "-x" help="Test"
#USAGE arg "[file]"
EOF
  run bash -c "source '$lib'; usage_spec" "$file"
  assert_success
  assert_line 'flag "-x" help="Test"'
  assert_line 'arg "[file]"'
}
