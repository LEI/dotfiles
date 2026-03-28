setup_file() {
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

# bats file_tags=chezmoi

# bats test_tags=feature,type:unit
@test "bin: chezmoi feature list" {
  run_chezmoi .local/bin/chezmoi-feature

  assert_line bash
  assert_line lla
  refute_stderr
  assert_success
}

# bats test_tags=feature,type:unit
@test "bin: chezmoi feature enabled" {
  run_chezmoi .local/bin/chezmoi-feature enabled

  assert_line bash
  refute_line lla
  refute_stderr
  assert_success
}

# bats test_tags=bin,package,type:unit
@test "bin: get package manager" {
  run_chezmoi .local/bin/package-manager

  assert_output
  refute_stderr
  assert_success
}

# bats test_tags=bin,package,type:unit
@test "bin: list expected packages" {
  run_chezmoi .local/bin/chezmoi-package list

  assert_output
  assert_stderr_line --regexp '# .* packages'
  assert_success
}

# bats test_tags=bin,package,type:unit
@test "bin: list installed packages" {
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

# bats test_tags=bin,brew,package,type:unit
@test "bin: list installed packages (brew)" {
  [ "$UNAME" != Darwin ] || skip "$UNAME"
  check_feature brew
  stub_seq brew 2
  run_chezmoi .local/bin/list-package brew
  unstub brew 2>/dev/null || true

  refute_output
  assert_stderr_line --regexp "^# STUB 1"
  assert_success
}

# bats test_tags=system,package,type:unit
@test "chezmoi: install packages" {
  [ "$UNAME" != Darwin ] || skip "$UNAME"
  run_chezmoi .chezmoiscripts/01-install-packages.sh

  refute_output
  assert_stderr_line --regexp "^DRY-RUN"
  assert_success
}

# bats test_tags=aur,package,type:unit
@test "chezmoi: install aur packages" {
  check_command pacman
  run_chezmoi .chezmoiscripts/linux/install-aur-packages.sh

  refute_output
  assert_stderr_line --regexp "^DRY-RUN: as_user"
  assert_success
}

# bats test_tags=brew,package,type:unit
@test "chezmoi: install brew packages" {
  check_feature brew
  stub_seq brew 3
  run_chezmoi .chezmoiscripts/02-install-brew-packages.sh
  unstub brew 2>/dev/null || true

  refute_output
  assert_stderr_line --regexp "^DRY-RUN: brew"
  assert_success
}

# bats test_tags=mise,package,type:unit
@test "chezmoi: install mise packages" {
  check_feature mise
  run_chezmoi .chezmoiscripts/01-install-tools.sh

  refute_output
  assert_stderr_line --regexp "^DRY-RUN"
  assert_success
}

# bats test_tags=python,package,type:smoke
@test "chezmoi: install python packages" {
  check_feature python
  run_chezmoi .chezmoiscripts/02-install-python.sh

  refute_output
  assert_stderr_line --regexp "^(Already installed|DRY-RUN: uv tool install)"
  assert_success
}

# bats test_tags=rust,package,type:smoke
@test "chezmoi: install rust packages" {
  check_feature rust
  run_chezmoi .chezmoiscripts/02-install-rust.sh

  refute_output
  assert_stderr_line "DRY-RUN: cargo --version"
  assert_success
}

# bats test_tags=xdg,type:unit
@test "chezmoi: install xdg" {
  run_chezmoi .chezmoiscripts/00-install-xdg.sh

  refute_output
  refute_stderr
  assert_success
}
