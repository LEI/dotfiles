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

# teardown() {
#   unstub run 2>/dev/null || true
# }

# bats file_tags=script

# bats test_tags=bootstrap
@test "script/bootstrap" {
  # stub curl; stub wget
  stub_seq chezmoi 2
  local chezmoi_args=("test" "--dry-run" "--refresh-externals=never") # ""
  run --separate-stderr bash ./script/bootstrap "${chezmoi_args[@]}"
  unstub chezmoi 2>/dev/null || true
  # assert_stderr_line --regexp "chezmoi init --apply .*${chezmoi_args[*]}"
  refute_output --partial "Tip:"
  assert_success
}

# bats test_tags=bench
@test "script/bench" {
  export BENCH_ITERATIONS=1
  stub_seq dummy $((BENCH_ITERATIONS + 2))
  run --separate-stderr bash ./script/bench dummy
  unstub dummy 2>/dev/null || true
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
  stub_seq chezmoi 2
  run --separate-stderr bash ./script/check
  unstub chezmoi 2>/dev/null || true
  refute_output
  # assert_stderr_line "Checking chezmoi..."
  # assert_stderr_line "Checking features..."
  # assert_stderr_line "Checking versions..."
  assert_success
}

# # bats test_tags=container
# @test "script/container" {
#   # stub_seq podman
#   for name in \
#     alpine \
#     archlinux \
#     debian ubuntu \
#     fedora \
#     macos \
#     termux; do
#     run --separate-stderr bash ./script/container "$name"
#     assert_output
#     # assert_stderr_line "Starting test container: test-$name-latest"
#     # assert_line --regexp "^container run .* --name=test-$name-latest"
#     assert_success
#   done
# }

# bats test_tags=container
@test "script/container" {
  local name=alpine
  export \
    GITHUB_TOKEN=nope \
    PROVIDER="echo container"
  run --separate-stderr bash ./script/container "$name"
  assert_output
  # assert_stderr_line "Starting test container: test-$name-latest"
  # assert_line --regexp "^container run .* --name=test-$name-latest"
  assert_success
}

# bats test_tags=container
@test "script/container (unknown argument)" {
  run --separate-stderr bash ./script/container unknown
  refute_output
  # assert_stderr
  assert_failure
}

# bats test_tags=install
@test "install password manager" {
  local package_manager
  package_manager="$(package-manager)"
  stub_seq "$package_manager" 3
  export CHEZMOI_COMMAND=test
  run --separate-stderr bash home/.install-password-manager.sh
  unstub "$package_manager" 2>/dev/null || true
  refute_output
  assert_success
}
