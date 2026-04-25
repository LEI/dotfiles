# shellcheck disable=SC2154,SC2016

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

  check_command jq
}

# bats file_tags=home,claude

# bats test_tags=type:smoke,managed
@test "claude: plugins/chezmoi has no unmanaged files" {
  no_unmanaged "$HOME/.claude/plugins/chezmoi"
}

# bats test_tags=type:smoke,plugins
@test "claude: ECC plugin is not installed at user scope" {
  local plugin_file="$HOME/.claude/plugins/installed_plugins.json"
  [ -f "$plugin_file" ] || skip "installed_plugins.json not present"
  run jq -r '.plugins["everything-claude-code@everything-claude-code"][]?.scope // empty' "$plugin_file"
  assert_success
  assert_output ""
}

# bats test_tags=type:smoke,plugins
@test "claude: settings.json is valid JSON" {
  local settings="$HOME/.claude/settings.json"
  [ -f "$settings" ] || skip "settings.json not present"
  run jq empty "$settings"
  assert_success
}
