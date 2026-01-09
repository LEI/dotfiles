setup_file() {
  # command -v chezmoi >/dev/null || skip "chezmoi: command not found"

  source test/common/setup-file.sh
  _common_setup_file

  export BATS_NO_PARALLELIZE_WITHIN_FILE=true
  # export BATS_TEST_RETRIES=1
  export CHEZMOI_WORKING_TREE=.
  export DRY_RUN=true
}

setup() {
  source test/common/setup.sh
  _common_setup

  source test/common/helper.sh

  # chezmoi=$(command -v chezmoi)
}

# teardown() {
#   unset chezmoi
# }

# bats file_tags=chezmoi

# bats test_tags=feature
@test "bin: chezmoi feature list" {
  # FIXME: assert_line.bash: line 173: lines: parameter not set
  # export BATS_TEST_RETRIES=1
  # skip container

  run_chezmoi .local/bin/chezmoi-feature # list
  # run --separate-stderr "$chezmoi" feature # list

  # assert_output --partial bash
  # assert_output --partial lla
  assert_line bash
  assert_line lla

  refute_stderr
  assert_success
}

# bats test_tags=feature
@test "bin: chezmoi feature enabled" {
  run_chezmoi .local/bin/chezmoi-feature enabled
  # run --separate-stderr "$chezmoi" feature enabled

  # assert_output --partial bash
  # refute_output --partial lla
  assert_line bash
  refute_line lla

  refute_stderr
  assert_success
}

# package-manager
# bats test_tags=bin,package
@test "bin: get package manager" {
  run_chezmoi .local/bin/package-manager
  assert_output
  refute_stderr
  assert_success
}

# chezmoi package list
# bats test_tags=bin,package
@test "bin: list expected packages" {
  run_chezmoi .local/bin/chezmoi-package list
  # run --separate-stderr "$chezmoi" package list

  assert_output
  assert_stderr_line --regexp '# .* packages'
  assert_success
}

# bats test_tags=bin,package
@test "bin: list installed packages" {
  # [ "${CI:-}" != true ] && skip "not in ci"
  local package_manager
  package_manager="$(package-manager)"
  if [ "$package_manager" = apt ]; then
    package_manager=apt-mark
  elif [ "$package_manager" = termux ]; then
    package_manager=pkg
  elif [ "$package_manager" = rpm ]; then
    package_manager=rpm-ostree
  fi
  stub_seq "$package_manager" 3
  run_chezmoi .local/bin/list-package
  unstub "$package_manager" 2>/dev/null || true
  refute_output
  assert_stderr_line --regexp "^# STUB"
  assert_success
}

# bats test_tags=bin,brew,package
@test "bin: list installed packages (brew)" {
  [ "$UNAME" != Darwin ] || skip "$UNAME"
  # skip "stub conflicts with feature test"
  check_feature brew
  # stub package-manager "echo brew"
  # bats::on_failure() {
  #   unstub package-manager 2>/dev/null || true
  # }
  stub_seq brew 2
  run_chezmoi .local/bin/list-package brew
  # unstub package-manager 2>/dev/null || true
  unstub brew 2>/dev/null || true
  refute_output
  assert_stderr_line --regexp "^# STUB 1"
  assert_success
}

# bats test_tags=system,package
@test "chezmoi: install packages" {
  [ "$UNAME" != Darwin ] || skip "$UNAME"
  # stub_seq sudo 4
  run_chezmoi .chezmoiscripts/01-install-packages.sh
  # unstub sudo 2>/dev/null || true
  # refute_output
  assert_stderr_line --regexp "Installing .* packages"
  assert_stderr_line --regexp "^DRY-RUN"
  assert_stderr_line --regexp "Installed .* packages"
  assert_success
}

# bats test_tags=aur,package
@test "chezmoi: install aur packages" {
  check_command pacman
  # command -v pacman >/dev/null || skip "$UNAME"
  stub_seq sudo 2
  run_chezmoi .chezmoiscripts/linux/install-aur-packages.sh
  unstub sudo 2>/dev/null || true
  assert_stderr_line --regexp "Installing .* packages"
  assert_stderr_line --regexp "^# STUB 1"
  assert_stderr_line --regexp "Installed .* packages"
  assert_success
}

# bats test_tags=brew,package
@test "chezmoi: install brew packages" {
  # skip "stub conflicts with feature test"
  check_feature brew
  stub_seq brew 3
  # skip "Commands brew update and brew bundle do not support --dry-run"
  run_chezmoi .chezmoiscripts/02-install-brew-packages.sh
  unstub brew 2>/dev/null || true
  refute_output
  assert_stderr_line "DRY-RUN: brew update --quiet"
  # assert_stderr_line "brew bundle --file=/dev/stdin --no-upgrade list"
  # assert_stderr_line "brew bundle --file=/dev/stdin --dry-run list"
  assert_stderr_line --regexp "^DRY-RUN: brew bundle --file=/dev/stdin" # --no-upgrade
  assert_success
}

# bats test_tags=mise,package
@test "chezmoi: install mise packages" {
  # skip "stub conflicts with feature test"
  check_feature mise
  # stub_seq mise 2
  stub_seq timeout 4
  run_chezmoi .chezmoiscripts/01-install-tools.sh
  # unstub mise 2>/dev/null || true
  unstub timeout 2>/dev/null || true
  # refute_output
  assert_stderr_line --regexp "^Installing tools"
  # assert_line --partial "Would install"
  assert_stderr_line "Installed tools"
  assert_success
}

# bats test_tags=python,package
@test "chezmoi: install python packages" {
  check_feature python
  # stub_seq uv
  run_chezmoi .chezmoiscripts/02-install-python.sh
  # unstub uv 2>/dev/null || true
  refute_output
  assert_stderr_line --partial "Already installed"
  assert_success
}

# bats test_tags=rust,package
@test "chezmoi: install rust packages" {
  check_feature rust
  run_chezmoi .chezmoiscripts/02-install-rust.sh
  refute_output
  assert_stderr_line "Already installed"
  assert_stderr_line "DRY-RUN: cargo --version"
  # assert_stderr_line --regexp "^DRY-RUN: cargo binstall"
  assert_success
}

# bats test_tags=xdg
@test "chezmoi: install xdg" {
  # FIXME: assert_success.bash: line 33: output: parameter not set
  # export BATS_TEST_RETRIES=1
  # skip container

  run_chezmoi .chezmoiscripts/00-install-xdg.sh
  assert_success
  refute_output
  refute_stderr
}
