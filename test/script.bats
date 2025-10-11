setup_file() {
  source test/common/setup-file.sh
  _common_setup_file

  # export BATS_NO_PARALLELIZE_WITHIN_FILE=true
  # export CHEZMOI_WORKING_TREE=.
  export DRY_RUN=true
}

setup() {
  source test/common/setup.sh
  _common_setup

  source test/common/helper.sh
}

teardown() {
  unstub chezmoi 2>/dev/null || true
  unstub dummy 2>/dev/null || true
  # unstub run 2>/dev/null || true
}

# bats file_tags=script

@test "script/bootstrap" {
  stub_seq chezmoi 2
  local chezmoi_args=("test" "--dry-run" "--refresh-externals=never")
  run --separate-stderr bash ./script/bootstrap "${chezmoi_args[@]}"
  # assert_stderr_line "Running 'chezmoi init --apply ${chezmoi_args[*]}'"
  refute_output --partial "Tip:"
  assert_success
}

# bats test_tags=check
@test "script/bench" {
  export BENCH_ITERATIONS=1
  local shell=dummy
  stub_seq "$shell" $((BENCH_ITERATIONS + 2))
  run --separate-stderr bash ./script/bench "$shell"
  # assert_output --partial "$shell average startup time"
  # assert_output --partial "$shell initial startup time"
  # assert_stderr_line --partial "bench 1/$BENCH_ITERATIONS: $shell"
  assert_success
  jq . <<<"$output" >/dev/null
}

# bats test_tags=check
@test "script/check" {
  # stub_seq chezmoi 5
  # stub_seq run 75
  # export \
  #   DOCTOR=true \
  #   DRYRUN=true \
  #   UPDATE=true
  run --separate-stderr bash ./script/check
  # assert_output
  # assert_stderr_line "Checking chezmoi..."
  # assert_stderr_line "Checking features..."
  # assert_stderr_line "Checking versions..."
  assert_success
}

@test "script/container" {
  # stub_seq podman
  export \
    GITHUB_TOKEN=nope \
    PROVIDER="echo container"
  for name in \
    alpine \
    archlinux \
    debian ubuntu \
    fedora \
    macos \
    termux; do
    run --separate-stderr bash ./script/container "$name"
    assert_output
    # assert_stderr_line "Starting test container: test-$name-latest"
    # assert_line --regexp "^container run .* --name=test-$name-latest"
    assert_success
  done
}

@test "script/container (unknown argument)" {
  run --separate-stderr bash ./script/container unknown
  refute_output
  # assert_stderr
  assert_failure
}
