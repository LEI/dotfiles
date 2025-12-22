setup_file() {
  source test/common/setup-file.sh
  _common_setup_file

  export BATS_NO_PARALLELIZE_WITHIN_FILE=true
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
  local chezmoi_args=(
    # "test"
    "--dry-run"
    "--refresh-externals=never"
  )
  export CI=true
  run --separate-stderr bash ./script/bootstrap "${chezmoi_args[@]}"
  assert_stderr_line "DRY-RUN: Running 'chezmoi init --apply --source=. ${chezmoi_args[*]}'"
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
  assert_stderr_line --partial "bench 1/$BENCH_ITERATIONS: dummy"
  assert_success
  jq . <<<"$output" >/dev/null
}

# bats test_tags=check
@test "script/check" {
  stub_seq timeout 8
  run --separate-stderr bash ./script/check
  unstub timeout 2>/dev/null || true
  # NOTE: atuin 15 on alpine has no doctor command
  # and timeout .. atuin hangs
  # if has_feature atuin && ! command -v apk >/dev/null; then
  #   assert_stderr_line --partial "atuin doctor"
  # fi
  if has_feature brew; then
    assert_stderr_line --partial "brew doctor"
  fi
  assert_stderr_line --partial "chezmoi doctor"
  if has_feature goss; then
    assert_stderr_line --partial "goss validate"
  fi
  if has_feature mise; then
    assert_stderr_line --partial "mise doctor"
  fi
  if has_feature neovim; then
    assert_stderr_line --partial nvim
  fi
  if has_feature tmux; then
    assert_stderr_line --partial tmux
  fi
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

# test_container() {
#   local name="$1"
#   export \
#     GITHUB_TOKEN=nope \
#     PROVIDER="echo container"
#
#   run --separate-stderr bash ./script/container "$name"
#   # assert_stderr_line "Starting test container: test-$name-latest"
#   # assert_line --regexp "^container run .* --name=test-$name-latest"
#   assert_line --partial "container compose"
#   assert_stderr_line "container: $name-latest"
#   refute_stderr_line --partial invalid
#   assert_success
# }
# # bats test_tags=container,image
# @test "script/container: alpine" {
#   test_container alpine
# }
# # bats test_tags=container,image
# @test "script/container: android" {
#   test_container android
# }
# # bats test_tags=container,image
# @test "script/container: archlinux" {
#   test_container archlinux
# }
# # bats test_tags=container,image
# @test "script/container: debian" {
#   test_container debian
# }
# # bats test_tags=container,image
# @test "script/container: ubuntu" {
#   test_container ubuntu
# }
# # bats test_tags=container,image
# @test "script/container: fedora" {
#   test_container fedora
# }
# # bats test_tags=container,image
# @test "script/container: macos" {
#   test_container macos
# }
#
# # bats test_tags=container
# @test "script/container: unknown" {
#   run --separate-stderr bash ./script/container unknown
#   refute_output
#   assert_stderr_line --partial invalid
#   assert_failure
# }

# bats test_tags=update
@test "script/update" {
  run --separate-stderr bash ./script/update
  if has_feature neovim; then
    assert_stderr_line --partial nvim
  fi
  if has_feature tmux; then
    assert_stderr_line --partial tmux
  fi
  assert_success
}

# bats test_tags=install
@test "install password manager" {
  # FIXME: `stub_seq "$package_manager" 3' failed
  # export BATS_TEST_RETRIES=1

  local package_manager
  # unstub package-manager 2>/dev/null || true
  package_manager="$(package-manager)"
  stub_seq "$package_manager" 3
  export CHEZMOI_COMMAND=test
  run --separate-stderr bash home/.install-password-manager.sh
  unstub "$package_manager" 2>/dev/null || true
  refute_output
  refute_stderr
  assert_success
}
