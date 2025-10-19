setup_file() {
  # command -v chezmoi >/dev/null || skip "chezmoi: command not found"

  source test/common/setup-file.sh
  _common_setup_file

  export BATS_NO_PARALLELIZE_WITHIN_FILE=true
  export CHEZMOI_WORKING_TREE=.
  export DRY_RUN=true
}

setup() {
  source test/common/setup.sh
  _common_setup

  source test/common/helper.sh
}

# teardown() {
#   unstub brew 2>/dev/null || true
# }

# bats file_tags=bin,chezmoi,packages

# bats test_tags=feature
@test "bin: chezmoi feature list" {
  unstub chezmoi 2>/dev/null || true
  # run_chezmoi .local/bin/chezmoi-feature # list
  run chezmoi feature # list

  # assert_output --partial bash
  # assert_output --partial lla
  assert_line bash
  assert_line lla

  # refute_stderr
  assert_success
}

# bats test_tags=feature
@test "bin: chezmoi feature enabled" {
  unstub chezmoi 2>/dev/null || true
  # run_chezmoi .local/bin/chezmoi-feature enabled
  run chezmoi feature enabled

  # assert_output --partial bash
  # refute_output --partial lla
  assert_line bash
  refute_line lla

  # refute_stderr
  assert_success
}

# package-manager
@test "bin: get package manager" {
  run_chezmoi .local/bin/package-manager
  assert_output
  # refute_stderr
  assert_success
}

# chezmoi package list
@test "bin: list expected packages" {
  run_chezmoi .local/bin/chezmoi-package list
  assert_output
  # assert_stderr_line --regexp '# .* packages'
  assert_success
}

# list-package
@test "bin: list installed packages" {
  # [ "${CI:-}" != true ] && skip "not in ci"
  # stub_seq sudo
  local package_manager
  package_manager="$(package-manager)"
  stub_seq "$package_manager" 3
  run_chezmoi .local/bin/list-package
  unstub "$package_manager" 2>/dev/null || true
  # assert_output
  # refute_stderr
  assert_success
}

@test "bin: list installed packages (brew)" {
  [ "$UNAME" = Darwin ] || skip "$UNAME"
  check_feature brew
  stub package-manager "echo brew"
  stub_seq brew 2
  run_chezmoi .local/bin/list-package # brew
  unstub brew 2>/dev/null || true
  refute_output
  # assert_stderr --partial "STUB"
  assert_success
}

@test "chezmoi: install packages" {
  [ "$UNAME" != Darwin ] || skip "$UNAME"
  stub_seq sudo 4 # 10
  run_chezmoi .chezmoiscripts/01-install-packages.sh
  unstub sudo 2>/dev/null || true
  refute_output
  # assert_stderr_line --regexp "Installing .* packages"
  # assert_stderr --partial "DRY-RUN:"
  # assert_stderr_line --regexp "Installed .* packages"
  assert_success
}

@test "chezmoi: install aur packages" {
  check_command pacman
  # command -v pacman >/dev/null || skip "$UNAME"
  stub_seq sudo 2
  run_chezmoi .chezmoiscripts/linux/install-aur-packages.sh
  unstub sudo 2>/dev/null || true
  # assert_stderr_line --regexp "Installing .* packages"
  # assert_stderr --partial "DRY-RUN:"
  # assert_stderr_line --regexp "Installed .* packages"
  assert_success
}

@test "chezmoi: install brew packages" {
  check_feature brew
  stub_seq brew 3
  # skip "Commands brew update and brew bundle do not support --dry-run"
  run_chezmoi .chezmoiscripts/02-install-brew-packages.sh
  unstub brew 2>/dev/null || true
  # assert_output
  refute_output
  # assert_stderr_line "DRY-RUN: brew update --quiet"
  # assert_stderr_line "brew bundle --file=/dev/stdin --no-upgrade list"
  assert_success
}

@test "chezmoi: install mise packages" {
  check_feature mise
  run_chezmoi .chezmoiscripts/01-install-tools.sh
  # assert_output
  # assert_stderr
  assert_success
}

@test "chezmoi: install python packages" {
  check_feature python
  run_chezmoi .chezmoiscripts/02-install-python.sh
  # assert_output
  # assert_stderr
  assert_success
}

@test "chezmoi: install rust packages" {
  check_feature rust
  run_chezmoi .chezmoiscripts/02-install-rust.sh
  assert_output
  # assert_stderr
  assert_success
}

@test "chezmoi: install xdg" {
  stub_seq ln
  stub_seq mv
  run_chezmoi .chezmoiscripts/00-install-xdg.sh
  unstub ln 2>/dev/null || true
  unstub mv 2>/dev/null || true
  refute_output
  # refute_stderr
  assert_success
}
