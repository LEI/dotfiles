setup_file() {
  source test/common/setup-file.sh
  _common_setup_file

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
  run --separate-stderr bash ./script/bootstrap "${chezmoi_args[@]}"
  assert_stderr_line "DRY-RUN: Running 'chezmoi init --apply --source=. ${chezmoi_args[*]}'"
  refute_output --partial "Tip:"
  assert_success
}

# bats test_tags=bench,type:unit
@test "script/bench" {
  export BENCH_ITERATIONS=1
  stub_seq dummy $((BENCH_ITERATIONS + 2))
  run --separate-stderr bash ./script/bench dummy
  unstub dummy 2>/dev/null || true
  assert_stderr_line --partial "bench 1/$BENCH_ITERATIONS: dummy"
  assert_success
  jq . <<<"$output" >/dev/null
}

# bats test_tags=check,type:unit
@test "script/check" {
  stub_seq timeout 8
  run --separate-stderr bash ./script/check
  unstub timeout 2>/dev/null || true
  if has_feature brew; then
    assert_stderr_line --regexp "# STUB .: timeout 5m brew doctor"
  fi
  assert_stderr_line --regexp "# STUB .: timeout 5m chezmoi doctor"
  if has_feature goss; then
    assert_stderr_line --regexp "# STUB .: timeout 5m goss validate"
  fi
  if has_feature mise; then
    assert_stderr_line --regexp "# STUB .: timeout 5m mise doctor"
  fi
  if has_feature neovim; then
    assert_stderr_line --regexp "# STUB .: timeout 5m nvim"
  fi
  if has_feature tmux; then
    assert_stderr_line --regexp "# STUB .: timeout 5m tmux"
  fi
  assert_success
}

# bats test_tags=update,type:unit
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

# bats test_tags=install,type:unit
@test "install password manager: skips on unknown command" {
  export CHEZMOI_COMMAND=test
  export CHEZMOI_WORKING_TREE="$PWD"
  run --separate-stderr bash home/.install-password-manager.sh
  refute_output
  refute_stderr
  assert_success
}

# bats test_tags=install,type:unit
@test "install password manager: exits if already installed" {
  stub bws "true"
  export CHEZMOI_COMMAND=apply
  export CHEZMOI_WORKING_TREE="$PWD"
  run --separate-stderr bash home/.install-password-manager.sh
  unstub bws 2>/dev/null || true
  refute_output
  refute_stderr
  assert_success
}
