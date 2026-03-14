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
  assert_stderr_line "DRY-RUN: Running 'chezmoi init --apply --source=$PWD ${chezmoi_args[*]}'"
  refute_output --regexp "Tip:"
  assert_success
}

# bats test_tags=startup,type:unit
@test "script/startup" {
  export BENCH_ITERATIONS=1
  export SHELL=dummy
  stub_seq dummy $((BENCH_ITERATIONS + 2))
  run --separate-stderr bash ./script/startup
  unstub dummy 2>/dev/null || true
  assert_stderr_line --regexp "startup 1/$BENCH_ITERATIONS: dummy -ci exit"
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
  # if has_feature tmux; then
  #   assert_stderr_line --regexp "# STUB .: timeout 5m tmux"
  # fi
  assert_success
}

# bats test_tags=update,type:unit
@test "script/update" {
  run --separate-stderr bash ./script/update
  if has_feature neovim; then
    assert_stderr_line --regexp "nvim"
  fi
  if has_feature tmux; then
    assert_stderr_line --regexp "tmux"
  fi
  assert_success
}

# bats test_tags=container,type:unit
@test "container: resolve sets expected vars for alpine" {
  source ./script/container
  resolve alpine
  assert_equal "$image_name" alpine
  assert_equal "$image_version" latest
  assert_equal "$image_name_arg" alpine
  assert_equal "$user" test
  assert_equal "$home" /home/test
  assert_equal "$container" chezmoi-alpine-latest
}

# bats test_tags=container,type:unit
@test "container: resolve sets expected vars for termux" {
  source ./script/container
  resolve termux
  assert_equal "$image_name" termux
  assert_equal "$image_name_arg" docker.io/termux/termux-docker
  assert_equal "$user" root
  assert_equal "$prefix" /data/data/com.termux/files
  assert_equal "$home" /data/data/com.termux/files/home
}

# bats test_tags=container,type:unit
@test "container: resolve handles version suffix" {
  source ./script/container
  resolve alpine:3.19
  assert_equal "$image_name" alpine
  assert_equal "$image_version" 3.19
  assert_equal "$container" chezmoi-alpine-3.19
}

# bats test_tags=install,type:unit
@test "install-password-manager: skips on unknown command" {
  export CHEZMOI_COMMAND=test
  export CHEZMOI_WORKING_TREE="$PWD"
  run --separate-stderr bash home/.install-password-manager.sh
  refute_output
  refute_stderr
  assert_success
}

# bats test_tags=install,type:unit
@test "install-password-manager: exits if already installed" {
  stub bws "true"
  export CHEZMOI_COMMAND=apply
  export CHEZMOI_WORKING_TREE="$PWD"
  run --separate-stderr bash home/.install-password-manager.sh
  unstub bws 2>/dev/null || true
  refute_output
  refute_stderr
  assert_success
}
