setup() {
  # shellcheck source=test/common/setup.sh
  source test/common/setup.sh
  _common_setup

  # shellcheck source=test/common/helper.sh
  source test/common/helper.sh
}

# bats file_tags=feature,type:smoke

@test "feature: atuin" {
  check_feature atuin
  run --separate-stderr atuin --version
  assert_success
  refute_stderr
  assert_output
}

@test "feature: bash" {
  check_feature bash
  run --separate-stderr bash --version
  assert_success
  refute_stderr
  assert_output
}

@test "feature: bat" {
  check_feature bat
  bat=bat
  if command -v batcat >/dev/null; then
    bat=batcat
  fi
  run --separate-stderr $bat --version
  assert_success
  refute_stderr
  assert_output
}

@test "feature: bottom" {
  check_feature bottom
  run --separate-stderr btm --version
  assert_success
  refute_stderr
  assert_output
}

@test "feature: carapace" {
  check_feature carapace
  run --separate-stderr carapace --version
  [ "$status" -ne 139 ] || skip "exit code 139" # mise reshim
  assert_success
  refute_stderr
  assert_output
}

@test "feature: direnv" {
  check_feature direnv
  run --separate-stderr direnv --version
  assert_success
  refute_stderr
  assert_output
}

@test "feature: eza" {
  check_feature eza
  run --separate-stderr eza --version
  assert_success
  refute_stderr
  assert_output
}

@test "feature: goss" {
  check_feature goss
  run --separate-stderr goss --version
  assert_success
  refute_stderr
  assert_output
}

@test "feature: helix" {
  check_feature helix
  run --separate-stderr hx --version
  assert_success
  refute_stderr
  assert_output
}

@test "feature: node" {
  check_feature node
  run --separate-stderr node --version
  assert_success
  refute_stderr
  assert_output
}

@test "feature: nushell" {
  check_feature nushell
  run --separate-stderr nu --version
  assert_success
  refute_stderr
  assert_output
}

@test "feature: neovim" {
  check_feature neovim
  run --separate-stderr nvim --version
  assert_success
  refute_stderr
  assert_output
}

@test "feature: python" {
  check_feature python
  python=python3
  if python --version >/dev/null 2>&1; then
    python=python
  fi
  run --separate-stderr $python --version
  assert_success
  refute_stderr
  assert_output
}

@test "feature: ripgrep" {
  check_feature ripgrep
  run --separate-stderr rg --version
  assert_success
  refute_stderr
  assert_output
}

@test "feature: tmux" {
  check_feature tmux
  run --separate-stderr tmux -V
  assert_success
  refute_stderr
  assert_output
}

@test "feature: topgrade" {
  check_feature topgrade
  run --separate-stderr topgrade --version
  assert_success
  refute_stderr
  assert_output
}

@test "feature: vim" {
  check_feature vim
  run --separate-stderr vim --version
  assert_success
  refute_stderr
  assert_output
}

@test "feature: zellij" {
  check_feature zellij
  run --separate-stderr zellij --version
  assert_success
  refute_stderr
  assert_output
}

@test "feature: zoxide" {
  check_feature zoxide
  run --separate-stderr zoxide --version
  assert_success
  refute_stderr
  assert_output
}

@test "feature: brew" {
  check_feature brew
  run --separate-stderr brew --version
  assert_success
  refute_stderr
  assert_output
}

@test "feature: chezmoi" {
  check_command chezmoi
  run --separate-stderr chezmoi --version
  assert_success
  refute_stderr
  assert_output
}

@test "feature: mise" {
  check_feature mise
  run mise --version
  assert_success
  assert_line --regexp '^[0-9]+\.[0-9]+\.[0-9]+'
}

@test "feature: zsh" {
  check_feature zsh
  run --separate-stderr zsh --version
  assert_success
  refute_stderr
  assert_output
}

@test "feature: jq" {
  check_command jq
  run --separate-stderr jq --version
  assert_success
  assert_output --partial 'jq-'
}

@test "feature: yq" {
  check_command yq
  run --separate-stderr yq --version
  assert_success
  refute_stderr
  assert_output --partial 'yq (https://github.com/mikefarah/yq/) version'
}

@test "binary: bws is unique in PATH" {
  skip "mise shim in path when non interctive"
  check_command bws
  run --separate-stderr which -a bws
  assert_success
  refute_stderr
  assert_output --regexp '^.+$'
  local count
  count=$(echo "$output" | wc -l | tr -d ' ')
  assert_equal 1 "$count"
}

@test "binary: zellij is unique in PATH" {
  # check_command zellij
  check_feature zellij
  run --separate-stderr which -a zellij
  assert_success
  refute_stderr
  assert_output --regexp '^.+$'
  local count
  count=$(echo "$output" | wc -l | tr -d ' ')
  assert_equal 1 "$count"
}
