# shellcheck disable=SC2154

setup_file() {
  # shellcheck source=test/common/setup-file.sh
  source test/common/setup-file.sh
  _common_setup_file
}

setup() {
  # shellcheck source=test/common/setup.sh
  source test/common/setup.sh
  _common_setup

  # shellcheck source=test/common/helper.sh
  source test/common/helper.sh
}

# bats file_tags=managed,strict

# bats test_tags=secrets
@test "secrets.d: no unmanaged files" {
  no_unmanaged "$HOME/.config/secrets.d"
}

# bats test_tags=claude
@test "claude: no unmanaged rules" {
  check_feature claude
  no_unmanaged "$HOME/.claude/rules"
}

# bats test_tags=claude
@test "claude: no unmanaged plugins" {
  check_feature claude
  no_unmanaged "$HOME/.claude/plugins/chezmoi"
}

# bats test_tags=claude,opkg
@test "claude: opkg local package is installed" {
  check_feature claude
  check_command opkg jq mise
  run --separate-stderr mise run opkg:tracked packages/local
  assert_success
}

# bats test_tags=neovim
@test "nvim: no unmanaged files" {
  check_feature neovim
  no_unmanaged "$HOME/.config/nvim"
}

# bats test_tags=opencode
@test "opencode: no unmanaged files" {
  check_feature opencode
  no_unmanaged "$HOME/.config/opencode"
}

# bats test_tags=opencode,opkg
@test "opencode: opkg local package is installed" {
  check_feature opencode
  check_command opkg jq mise
  run --separate-stderr mise run opkg:tracked packages/local
  assert_success
}

# bats test_tags=opkg
@test "openpackage: no unmanaged files" {
  check_command opkg jq mise
  run --separate-stderr mise run opkg:unmanaged
  assert_success
  run --separate-stderr exclude_under_symlink <<<"$output"
  assert_success
  refute_stderr
  refute_output
}
