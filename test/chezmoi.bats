setup_file() {
  command -v chezmoi >/dev/null || skip "chezmoi: command not found"

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

teardown() {
  unstub brew 2>/dev/null || true
  unstub ln 2>/dev/null || true
  unstub mv 2>/dev/null || true
  unstub package-manager 2>/dev/null || true
  unstub sudo 2>/dev/null || true
}

# bats file_tags=bin,chezmoi,packages

# package-manager
@test "bin: get package manager" {
  run_chezmoi .local/bin/package-manager
  assert_output
  refute_stderr
  assert_success
}

# chezmoi package list
@test "bin: list expected packages" {
  run_chezmoi .local/bin/chezmoi-package list
  assert_output
  assert_stderr_line --regexp '# .* packages'
  assert_success
}

# list-package
@test "bin: list installed packages" {
  # [ "${CI:-}" != true ] && skip "not in ci"
  # stub_seq sudo
  run_chezmoi .local/bin/list-package
  assert_output
  refute_stderr
  assert_success
}
@test "bin: list installed packages (brew)" {
  [ "$UNAME" = Darwin ] || skip "$UNAME"
  stub package-manager "echo brew"
  stub_seq brew
  run_chezmoi .local/bin/list-package # brew
  refute_output
  assert_stderr --partial "STUB"
  assert_success
}

@test "chezmoi: install packages" {
  stub_seq sudo 2
  run_chezmoi .chezmoiscripts/01-install-packages.sh
  refute_output
  assert_stderr_line --regexp "Installing .* packages"
  # assert_stderr --partial "DRY-RUN:"
  assert_stderr_line --regexp "Installed .* packages"
  assert_success
}

@test "chezmoi: install aur packages" {
  # command -v pacman >/dev/null || skip "$UNAME"
  stub_seq sudo
  run_chezmoi .chezmoiscripts/linux/install-aur-packages.sh
  assert_stderr_line --regexp "Installing .* packages"
  # assert_stderr --partial "DRY-RUN:"
  assert_stderr_line --regexp "Installed .* packages"
  assert_success
}

@test "chezmoi: install brew packages" {
  stub_seq brew
  # skip "Commands brew update and brew bundle do not support --dry-run"
  run_chezmoi .chezmoiscripts/02-install-brew-packages.sh
  # assert_output
  refute_output
  assert_stderr_line "DRY-RUN: brew update --quiet"
  assert_stderr_line "brew bundle --file=/dev/stdin --no-upgrade list"
  assert_success
}

@test "chezmoi: install mise packages" {
  run_chezmoi .chezmoiscripts/01-install-tools.sh
  assert_output
  assert_stderr
  assert_success
}

@test "chezmoi: install python packages" {
  run_chezmoi .chezmoiscripts/02-install-python.sh
  # assert_output
  assert_stderr
  assert_success
}

@test "chezmoi: install rust packages" {
  run_chezmoi .chezmoiscripts/02-install-rust.sh
  assert_output
  assert_stderr
  assert_success
}

@test "chezmoi: install xdg" {
  stub_seq ln
  stub_seq mv
  run_chezmoi .chezmoiscripts/00-install-xdg.sh
  refute_output
  refute_stderr
  assert_success
}
