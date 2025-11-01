setup() {
  source test/common/setup.sh
  _common_setup

  source test/common/helper.sh

  # brew=$(command -v brew 2>/dev/null || echo brew)
}

# bats file_tags=dotfiles,home

@test "macos: script exists and is executable" {
  [ "$UNAME" = Darwin ] || skip "$UNAME"
  # [ -f ~/.macos ]
  [ -x ~/.macos ]
}

# @test "brew installation script runs without errors" {
#   run bash install/macos/common/brew.sh
#   [ "$status" -eq 0 ]
# }

# @test "brew command is available after installation" {
#   run command -v brew
#   [ "$status" -eq 0 ]
# }

@test "feature: atuin" {
  check_feature atuin
  run --separate-stderr atuin --version
  assert_output
  refute_stderr
  assert_success
  # ble.sh
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
  # ble.sh
}

@test "feature: bottom" {
  check_feature bottom
  run --separate-stderr btm --version
  assert_output
  refute_stderr
  assert_success
}

# @test "feature: brew" {
#   check_feature brew
#   run --separate-stderr "$brew" --version
#   assert_output
#   refute_stderr
#   assert_success
# }

@test "feature: carapace" {
  check_feature carapace
  run --separate-stderr carapace --version
  assert_output
  refute_stderr
  assert_success
}

@test "feature: direnv" {
  check_feature direnv
  run --separate-stderr direnv --version
  assert_output
  refute_stderr
  assert_success
  # direnv export bash
}

@test "feature: eza" {
  check_feature eza
  run --separate-stderr eza --version # | head -n2 | tail -n1
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

# @test "feature: mise" {
#   check_feature mise
#   run --separate-stderr mise --version # | head -n1
#   assert_output
#   # refute_stderr # mise WARN  mise version .* available
#   assert_success
# }

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
  python=python
  if ! command -v python >/dev/null && command -v python3 >/dev/null; then
    python=python3
  fi
  run --separate-stderr $python --version
  assert_output
  refute_stderr
  assert_success
  # pipx, uvx
}

@test "feature: ripgrep" {
  check_feature ripgrep
  run --separate-stderr rg --version # | head -n1
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

@test "feature: zsh" {
  check_feature zsh
  run --separate-stderr zsh --version
  assert_output
  refute_stderr
  assert_success
}
