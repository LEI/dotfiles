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

# Checks whether an opkg package is tracked globally
_opkg_tracked() {
  opkg list --global --json 2>/dev/null |
    jq -e "[.data.resources[] | .resources[] | select(.name == \"packages/$1\" and .status == \"tracked\")] | length > 0" \
      >/dev/null 2>&1
}

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
  check_command opkg jq
  _opkg_tracked "local" || fail "opkg package 'local' is not tracked"
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
  check_command opkg jq
  _opkg_tracked "local" || fail "opkg package 'local' is not tracked"
}
