setup() {
  source test/common/setup.sh
  _common_setup

  source test/common/helper.sh
}

# bats file_tags=feature,type:smoke

@test "feature: atuin" {
  check_feature atuin
  run --separate-stderr atuin --version
  assert_output
  refute_stderr
  assert_success
}

@test "feature: bash" {
  check_feature bash
  run --separate-stderr bash --version
  assert_output
  refute_stderr
  assert_success
}

@test "feature: bat" {
  check_feature bat
  bat=bat
  if command -v batcat >/dev/null; then
    bat=batcat
  fi
  run --separate-stderr $bat --version
  assert_output
  refute_stderr
  assert_success
}

@test "feature: bottom" {
  check_feature bottom
  run --separate-stderr btm --version
  assert_output
  refute_stderr
  assert_success
}

@test "feature: carapace" {
  check_feature carapace
  run carapace --version
  assert_output
  assert_success
}

@test "feature: direnv" {
  check_feature direnv
  run --separate-stderr direnv --version
  assert_output
  refute_stderr
  assert_success
}

@test "feature: eza" {
  check_feature eza
  run --separate-stderr eza --version
  assert_output
  refute_stderr
  assert_success
}

@test "feature: goss" {
  check_feature goss
  run --separate-stderr goss --version
  assert_output
  refute_stderr
  assert_success
}

@test "feature: helix" {
  check_feature helix
  run --separate-stderr hx --version
  assert_output
  refute_stderr
  assert_success
}

@test "feature: node" {
  check_feature node
  run --separate-stderr node --version
  assert_output
  refute_stderr
  assert_success
}

@test "feature: nushell" {
  check_feature nushell
  run --separate-stderr nu --version
  assert_output
  refute_stderr
  assert_success
}

@test "feature: neovim" {
  check_feature neovim
  run --separate-stderr nvim --version
  assert_output
  refute_stderr
  assert_success
}

@test "feature: python" {
  check_feature python
  python=python3
  if python --version >/dev/null 2>&1; then
    python=python
  fi
  run --separate-stderr $python --version
  assert_output
  refute_stderr
  assert_success
}

@test "feature: ripgrep" {
  check_feature ripgrep
  run --separate-stderr rg --version
  assert_output
  refute_stderr
  assert_success
}

@test "feature: tmux" {
  check_feature tmux
  run --separate-stderr tmux -V
  assert_output
  refute_stderr
  assert_success
}

@test "feature: topgrade" {
  check_feature topgrade
  run --separate-stderr topgrade --version
  assert_output
  refute_stderr
  assert_success
}

@test "feature: vim" {
  check_feature vim
  run --separate-stderr vim --version
  assert_output
  refute_stderr
  assert_success
}

@test "feature: zellij" {
  check_feature zellij
  run --separate-stderr zellij --version
  assert_output
  refute_stderr
  assert_success
}

@test "feature: zoxide" {
  check_feature zoxide
  run --separate-stderr zoxide --version
  assert_output
  refute_stderr
  assert_success
}

@test "feature: brew" {
  check_feature brew
  run --separate-stderr brew --version
  assert_output
  refute_stderr
  assert_success
}

@test "feature: chezmoi" {
  check_command chezmoi
  run --separate-stderr chezmoi --version
  assert_output
  refute_stderr
  assert_success
}

@test "feature: mise" {
  check_feature mise
  run mise --version
  assert_line --regexp '^[0-9]+\.[0-9]+\.[0-9]+'
  assert_success
}

@test "feature: zsh" {
  check_feature zsh
  run --separate-stderr zsh --version
  assert_output
  refute_stderr
  assert_success
}
