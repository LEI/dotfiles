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
@test "claude: no unmanaged files" {
  check_feature claude
  no_unmanaged "$HOME/.claude"
}

# bats test_tags=claude,opkg
@test "claude: opkg local package is installed" {
  check_feature claude
  check_command opkg jq mise
  run --separate-stderr mise --cd "$HOME/.openpackage" run opkg:tracked local
  assert_success
}

# bats test_tags=claude
@test "claude: no MCP servers outside .mcp.json" {
  check_feature claude
  check_command jq chezmoi
  [ -f "$HOME/.claude.json" ] || skip "no .claude.json"

  local mcp name
  local orphans=()
  mcp=$(chezmoi execute-template --no-tty \
    '{{ includeTemplate "dot_claude/.mcp.json.tmpl" . }}') ||
    fail "failed to render .mcp.json.tmpl"

  while IFS= read -r name; do
    [ -n "$name" ] || continue
    [ "$(jq --arg n "$name" 'index($n) != null' <<<"$mcp")" = true ] ||
      orphans+=("$name")
  done < <(jq -r '.mcpServers // {} | keys[]' "$HOME/.claude.json")

  [ ${#orphans[@]} -eq 0 ] && return 0

  local cmds=""
  for name in "${orphans[@]}"; do
    cmds="${cmds}claude mcp remove \"$name\""$'\n'
  done
  fail "MCP servers not in .mcp.json:"$'\n'"$cmds"
}

# bats test_tags=claude,plugins
@test "claude: cached plugins match deployed source" {
  check_feature claude
  assert_plugin_cache_fresh "$HOME/.claude/plugins"
}

# bats test_tags=neovim
@test "nvim: no unmanaged files" {
  check_feature neovim
  no_unmanaged "$HOME/.config/nvim"
}

# bats test_tags=pi
@test "pi: no unmanaged files" {
  check_feature pi
  no_unmanaged "$HOME/.config/pi"
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
  run --separate-stderr mise --cd "$HOME/.openpackage" run opkg:tracked local
  assert_success
}

# bats test_tags=opkg
@test "openpackage: no unmanaged files" {
  [ -d "$HOME/.openpackage" ] || skip "no openpackage workspace"
  no_unmanaged "$HOME/.openpackage"
}

# bats test_tags=opkg
@test "opkg: tasks are scoped to ~/.openpackage, not the global config" {
  check_command mise
  [ -d "$HOME/.openpackage/mise-tasks/opkg" ] || skip "opkg tasks not applied"

  # Discoverable within the openpackage tree
  run --separate-stderr mise --cd "$HOME/.openpackage" tasks ls
  assert_success
  assert_output --partial "opkg:tracked"

  # Not leaking into unrelated directories: the global config defines no opkg
  run --separate-stderr mise --cd "$BATS_TEST_TMPDIR" tasks ls
  assert_success
  refute_output --partial "opkg:tracked"
}

# bats test_tags=opkg
@test "opkg: local package installs match source" {
  local src="$HOME/.openpackage/packages/local"
  [ -d "$src" ] || skip "no local package source"

  local platforms=()
  has_feature claude && platforms+=("$HOME/.claude")
  has_feature opencode && platforms+=("$HOME/.config/opencode")
  [ ${#platforms[@]} -gt 0 ] || skip "no platforms enabled"

  local errs="" p kind s n entry
  for p in "${platforms[@]}"; do
    # No opkg auto-namespacing leftovers (e.g., ~/.claude/skills/local-sq)
    for kind in agents skills commands; do
      [ -d "$p/$kind" ] || continue
      for entry in "$p/$kind"/local-* "$p/$kind"/local; do
        [ -e "$entry" ] || [ -L "$entry" ] || continue
        errs="${errs}stale: $entry"$'\n'
      done
    done
    # Each source resource must be installed at natural path
    for kind in agents commands; do
      [ -d "$src/$kind" ] || continue
      for s in "$src/$kind"/*.md; do
        [ -e "$s" ] || continue
        n=$(basename "$s")
        [ -e "$p/$kind/$n" ] || errs="${errs}missing: $p/$kind/$n"$'\n'
      done
    done
    if [ -d "$src/skills" ]; then
      for s in "$src/skills"/*/; do
        [ -d "$s" ] || continue
        n=$(basename "$s")
        [ -e "$p/skills/$n/SKILL.md" ] || errs="${errs}missing: $p/skills/$n/SKILL.md"$'\n'
      done
    fi
  done

  [ -z "$errs" ] || fail "$errs"
}

# bats test_tags=rules
@test "rules: top-level entries are symlinks only" {
  local dirs
  dirs=$(discover_rule_dirs)
  [ -n "$dirs" ] || skip "no rule dirs discovered"

  local dir entry strays=""
  while IFS= read -r dir; do
    for entry in "$dir"/* "$dir"/.[!.]*; do
      [ -e "$entry" ] || [ -L "$entry" ] || continue
      [ -L "$entry" ] && continue
      strays="${strays}${entry}"$'\n'
    done
  done <<<"$dirs"

  [ -z "$strays" ] || fail "non-symlink entries in rule dirs:"$'\n'"$strays"
}
