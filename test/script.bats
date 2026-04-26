# shellcheck disable=SC2154

setup_file() {
  source test/common/setup-file.sh
  _common_setup_file

  # export BATS_NO_PARALLELIZE_WITHIN_FILE=true
  export DRY_RUN=true
}

setup() {
  source test/common/setup.sh
  _common_setup

  source test/common/helper.sh
}

# bats file_tags=script

# bats test_tags=bootstrap,type:unit
@test "script/bootstrap" {
  local chezmoi_args=(
    "--dry-run"
    "--refresh-externals=never"
  )
  export CI=true
  run_script ./script/bootstrap "${chezmoi_args[@]}"

  refute_output --regexp "Tip:"
  assert_stderr_line "DRY-RUN: Running 'chezmoi init --apply --source=$PWD ${chezmoi_args[*]}'"
  assert_success
}

# bats test_tags=startup,type:unit
@test "script/startup" {
  check_command time
  export BENCH_ITERATIONS=1
  export SHELL=dummy
  stub_seq dummy $((BENCH_ITERATIONS + 2))
  run_script ./script/startup
  unstub dummy 2>/dev/null || true

  assert_stderr_line --regexp "startup 1/$BENCH_ITERATIONS: dummy -ci exit"
  assert_success
  jq . <<<"$output" >/dev/null
}

# bats test_tags=check,type:unit
# @test "script/check" {
#   stub_seq goss 1
#   stub_seq mise 1
#   stub_seq nvim 1
#   run_script ./script/check
#   unstub goss 2>/dev/null || true
#   unstub mise 2>/dev/null || true
#   unstub nvim 2>/dev/null || true
#
#   if has_feature goss; then
#     assert_stderr_line "Checking goss"
#   fi
#   if has_feature mise; then
#     assert_stderr_line "Checking mise"
#   fi
#   if has_feature neovim; then
#     assert_stderr_line "Checking nvim"
#   fi
#   assert_success
# }

# bats test_tags=install,type:unit
@test "install-password-manager: skips on unknown command" {
  # shellcheck disable=SC2030,SC2031
  export CHEZMOI_COMMAND=test
  # shellcheck disable=SC2030,SC2031
  export CHEZMOI_WORKING_TREE="$PWD"
  run_script home/.install-password-manager.sh

  refute_output
  refute_stderr
  assert_success
}

# bats test_tags=install,type:unit
@test "install-password-manager: exits if already installed" {
  stub bws "true"
  # shellcheck disable=SC2030,SC2031
  export CHEZMOI_COMMAND=apply
  # shellcheck disable=SC2030,SC2031
  export CHEZMOI_WORKING_TREE="$PWD"
  run_script home/.install-password-manager.sh
  unstub bws 2>/dev/null || true

  refute_output
  refute_stderr
  assert_success
}
