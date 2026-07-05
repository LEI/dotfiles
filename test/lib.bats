setup() {
  # shellcheck source=test/common/setup.sh
  source test/common/setup.sh
  _common_setup
  ORIG_PATH=$PATH
}

teardown() {
  PATH=$ORIG_PATH
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
  local dir="$BATS_TEST_TMPDIR/prepend"
  mkdir -p "$dir"
  setup_pathmunge
  pathmunge "$dir"
  [[ "$PATH" == "$dir:"* ]]
}

@test "pathmunge: appends directory with after" {
  local dir="$BATS_TEST_TMPDIR/append"
  mkdir -p "$dir"
  setup_pathmunge
  pathmunge "$dir" after
  [[ "$PATH" == *":$dir" ]]
}

@test "pathmunge: skips duplicate directory" {
  local dir="$BATS_TEST_TMPDIR/dup"
  mkdir -p "$dir"
  setup_pathmunge
  pathmunge "$dir"
  local first_path="$PATH"
  run pathmunge "$dir"
  assert_success
  [ "$PATH" = "$first_path" ]
}

@test "pathmunge: replace removes and re-prepends existing entry" {
  local dir="$BATS_TEST_TMPDIR/repl"
  mkdir -p "$dir"
  setup_pathmunge
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
  lib_dir=home/dot_local/lib
  # shellcheck source=home/dot_local/lib/sh/parallel.sh
  source "$lib_dir/sh/parallel.sh"
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

setup_usage() {
  # shellcheck source=home/dot_local/lib/sh/usage.sh
  source home/dot_local/lib/sh/usage.sh
}

@test "usage_spec: extracts #USAGE lines stripped of prefix" {
  setup_usage
  local lib="$PWD/home/dot_local/lib/sh/usage.sh"
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

# redact

setup_redact() {
  # shellcheck source=home/dot_local/lib/sh/redact.sh
  source home/dot_local/lib/sh/redact.sh
}

@test "redact_arg: masks TOKEN value" {
  setup_redact
  run redact_arg "GITHUB_TOKEN=secret123"
  assert_success
  assert_output "GITHUB_TOKEN=[REDACTED]"
}

@test "redact_arg: masks SECRET, PASSWORD, PASS, PRIVATE_KEY" {
  setup_redact
  run redact_arg "DB_SECRET=abc"
  assert_output "DB_SECRET=[REDACTED]"
  run redact_arg "USER_PASSWORD=hunter2"
  assert_output "USER_PASSWORD=[REDACTED]"
  run redact_arg "SUDO_PASS=letmein"
  assert_output "SUDO_PASS=[REDACTED]"
  run redact_arg "SSH_PRIVATE_KEY=-----BEGIN"
  assert_output "SSH_PRIVATE_KEY=[REDACTED]"
}

@test "redact_arg: passes non-secret args through unchanged" {
  setup_redact
  run redact_arg "FOO=bar"
  assert_output "FOO=bar"
  run redact_arg "plain-string"
  assert_output "plain-string"
}

@test "redact_arg: empty value is not redacted" {
  setup_redact
  run redact_arg "TOKEN="
  assert_output "TOKEN="
}

# anthropic_quota_label

setup_anthropic() {
  # shellcheck source=home/dot_local/lib/sh/anthropic.sh
  source home/dot_local/lib/sh/anthropic.sh
}

@test "anthropic_quota_label: known keys render byte-identical to today's labels" {
  setup_anthropic
  assert_equal "$(anthropic_quota_label five_hour)" "5h quota"
  assert_equal "$(anthropic_quota_label seven_day)" "7d all models"
  assert_equal "$(anthropic_quota_label seven_day_sonnet)" "7d sonnet"
  assert_equal "$(anthropic_quota_label seven_day_opus)" "7d opus"
  assert_equal "$(anthropic_quota_label seven_day_omelette)" "7d design"
  assert_equal "$(anthropic_quota_label seven_day_oauth_apps)" "7d oauth apps"
  assert_equal "$(anthropic_quota_label seven_day_cowork)" "7d cowork"
  assert_equal "$(anthropic_quota_label omelette_promotional)" "design promo"
}

@test "anthropic_quota_label: unmapped seven_day_ key renders as 7d <name>" {
  setup_anthropic
  assert_equal "$(anthropic_quota_label seven_day_fable)" "7d fable"
}

@test "anthropic_quota_label: unknown non seven_day_ key passes through" {
  setup_anthropic
  assert_equal "$(anthropic_quota_label mystery_field)" "mystery_field"
}

# anthropic_scope_prefix

@test "anthropic_scope_prefix: known groups map to duration prefixes" {
  setup_anthropic
  assert_equal "$(anthropic_scope_prefix session)" "5h"
  assert_equal "$(anthropic_scope_prefix weekly)" "7d"
}

@test "anthropic_scope_prefix: unknown group passes through" {
  setup_anthropic
  assert_equal "$(anthropic_scope_prefix monthly)" "monthly"
}

# cache

setup_cache() {
  # shellcheck source=home/dot_local/lib/sh/cache.sh
  source home/dot_local/lib/sh/cache.sh
}

@test "cache_backoff_active: no failure recorded returns false" {
  setup_cache
  run cache_backoff_active "$BATS_TEST_TMPDIR/quota.json" 60
  assert_failure
}

@test "cache_backoff_active: recent failure returns true within backoff window" {
  setup_cache
  cache_mark_failed "$BATS_TEST_TMPDIR/quota.json"
  run cache_backoff_active "$BATS_TEST_TMPDIR/quota.json" 60
  assert_success
}

@test "cache_clear_failed: removes a recorded failure" {
  setup_cache
  cache_mark_failed "$BATS_TEST_TMPDIR/quota.json"
  cache_clear_failed "$BATS_TEST_TMPDIR/quota.json"
  run cache_backoff_active "$BATS_TEST_TMPDIR/quota.json" 60
  assert_failure
}

@test "cache_backoff_remaining: no failure recorded prints nothing" {
  setup_cache
  run cache_backoff_remaining "$BATS_TEST_TMPDIR/quota.json" 60
  assert_success
  assert_output ""
}

@test "cache_backoff_remaining: recent failure prints seconds left" {
  setup_cache
  cache_mark_failed "$BATS_TEST_TMPDIR/quota.json"
  run cache_backoff_remaining "$BATS_TEST_TMPDIR/quota.json" 60
  assert_success
  [ "$output" -gt 0 ] && [ "$output" -le 60 ]
}

# duration

setup_duration() {
  # shellcheck source=home/dot_local/lib/sh/duration.sh
  source home/dot_local/lib/sh/duration.sh
}

@test "humanize_secs: formats various durations" {
  setup_duration
  assert_equal "$(humanize_secs 45)" "45s"
  assert_equal "$(humanize_secs 90)" "1m"
  assert_equal "$(humanize_secs 3661)" "1h 1m"
  assert_equal "$(humanize_secs 90000)" "1d 1h"
}

@test "parse_epoch: round-trips a bare epoch integer" {
  setup_duration
  assert_equal "$(parse_epoch 1700000000)" "1700000000"
}

@test "parse_epoch: parses an ISO 8601 timestamp" {
  setup_duration
  assert_equal "$(TZ=UTC parse_epoch "2023-11-14T22:13:20Z")" "1700000000"
}

@test "parse_epoch: fails on unparseable input" {
  setup_duration
  run parse_epoch "not-a-date"
  assert_failure
}

@test "format_date: formats a known epoch" {
  setup_duration
  assert_equal "$(TZ=UTC format_date 1700000000)" "Nov 14, 10:13pm"
}

@test "format_date_relative: future timestamp shows relative duration, no ago suffix" {
  setup_duration
  future=$(($(date +%s) + 7200))
  run format_date_relative "$future"
  assert_success
  [[ "$output" == *"("*")" ]]
  [[ "$output" != *" ago)" ]]
}

@test "format_date_relative: past timestamp appends ago suffix" {
  setup_duration
  past=$(($(date +%s) - 7200))
  run format_date_relative "$past"
  assert_success
  [[ "$output" == *" ago)" ]]
}

# quote

setup_quote() {
  # shellcheck source=home/dot_local/lib/sh/log.sh
  source home/dot_local/lib/sh/log.sh
}

@test "quote_arg: leaves safe chars unchanged" {
  setup_quote
  run quote_arg "/path/to/file.txt"
  assert_output "/path/to/file.txt"
  run quote_arg "abc-def_123@host.com"
  assert_output "abc-def_123@host.com"
}

@test "quote_arg: quotes empty string" {
  setup_quote
  run quote_arg ""
  assert_output "''"
}

@test "quote_arg: quotes args with spaces" {
  setup_quote
  run quote_arg "hello world"
  assert_output "'hello world'"
}

@test "quote_arg: escapes embedded single quotes" {
  setup_quote
  run quote_arg "it's"
  assert_output "'it'\\''s'"
}

@test "quote_arg: quotes shell metacharacters" {
  setup_quote
  # shellcheck disable=SC2016
  run quote_arg 'cost is $5'
  assert_output "'cost is \$5'"
}

@test "quote_args: joins multiple safe args with spaces" {
  setup_quote
  run quote_args foo bar baz
  assert_output "foo bar baz"
}

@test "quote_args: mixes safe and unsafe args" {
  setup_quote
  run quote_args foo "hello world" bar
  assert_output "foo 'hello world' bar"
}

@test "quote_args: returns empty for no args" {
  setup_quote
  run quote_args
  assert_output ""
}
