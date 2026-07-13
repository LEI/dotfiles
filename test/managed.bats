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

# bats test_tags=secrets
@test "secrets.d: no plaintext secret literals" {
  check_command keystore
  run keystore audit
  assert_success
  refute_output
}

# bats test_tags=secrets
@test "secrets.d: opencode.conf stays a systemd-literal EnvironmentFile" {
  check_feature opencode
  check_command chezmoi

  run chezmoi cat "$HOME/.config/secrets.d/opencode.conf"
  assert_success
  refute_output --partial '$'
  refute_output --partial 'keystore_export'
  refute_output --partial 'export_nonempty'
  refute_output --partial 'keystore_get'
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
  # skills left opkg (deployed as symlinks); local's opkg resources are its
  # agents/commands, which register under namespaced sub-package keys
  run --separate-stderr mise --cd "$HOME/.openpackage" run opkg:tracked local/agents/readonly.md
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
  # skills left opkg (deployed as symlinks); local's opkg resources are its
  # agents/commands, which register under namespaced sub-package keys
  run --separate-stderr mise --cd "$HOME/.openpackage" run opkg:tracked local/agents/readonly.md
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
  done

  [ -z "$errs" ] || fail "$errs"
}

# bats test_tags=rules
@test "rules: top-level entries are symlinks only" {
  local dirs
  dirs=$(discover_rule_dirs)
  [ -n "$dirs" ] || skip "no rule dirs discovered"

  local dir entry strays="" dangling=""
  while IFS= read -r dir; do
    for entry in "$dir"/* "$dir"/.[!.]*; do
      [ -e "$entry" ] || [ -L "$entry" ] || continue
      [ -L "$entry" ] && continue
      strays="${strays}${entry}"$'\n'
    done
    while IFS= read -r entry; do
      dangling="${dangling}${entry}"$'\n'
    done < <(find "$dir" -type l ! -exec test -e {} \; -print)
  done <<<"$dirs"

  [ -z "$strays" ] || fail "non-symlink entries in rule dirs:"$'\n'"$strays"
  [ -z "$dangling" ] || fail "dangling symlinks in rule dirs (deleted source):"$'\n'"$dangling"
}

# bats test_tags=skills
@test "skills: top-level entries are symlinks only" {
  local dirs
  dirs=$(discover_skill_dirs)
  [ -n "$dirs" ] || skip "no skill dirs discovered"

  local dir entry strays="" dangling=""
  while IFS= read -r dir; do
    for entry in "$dir"/* "$dir"/.[!.]*; do
      [ -e "$entry" ] || [ -L "$entry" ] || continue
      [ -L "$entry" ] && continue
      strays="${strays}${entry}"$'\n'
    done
    while IFS= read -r entry; do
      dangling="${dangling}${entry}"$'\n'
    done < <(find "$dir" -type l ! -exec test -e {} \; -print)
  done <<<"$dirs"

  [ -z "$strays" ] || fail "non-symlink entries in skill dirs:"$'\n'"$strays"
  [ -z "$dangling" ] || fail "dangling symlinks in skill dirs (deleted source):"$'\n'"$dangling"
}

# bats test_tags=rules,skills
@test "dangling symlink scan detects a broken link" {
  local dir="$BATS_TEST_TMPDIR/scan-fixture"
  mkdir -p "$dir"
  ln -s "$dir/deleted-source" "$dir/dangling"

  local entry dangling=""
  while IFS= read -r entry; do
    dangling="${dangling}${entry}"$'\n'
  done < <(find "$dir" -type l ! -exec test -e {} \; -print)

  [ -n "$dangling" ] || fail "scan did not detect dangling symlink in $dir"
}

# bats test_tags=rules,skills,opkg
@test "opkg: orphan prune removes symlinks gone from the desired set or with a missing source" {
  local dir="$BATS_TEST_TMPDIR/prune-fixture"
  mkdir -p "$dir"
  : >"$dir/target"

  # keep-valid: in the desired set with a live source, kept
  ln -s "$dir/target" "$dir/keep-valid"
  # stale-source: in the desired set but its source is gone, pruned
  ln -s "$dir/deleted-source" "$dir/stale-source"
  # dropped-name: source is live but the name left the desired set, pruned
  ln -s "$dir/target" "$dir/dropped-name"

  # Mirror the prune loop from run_onchange_after_publish-opkg.sh.tmpl,
  # rm stands in for trash since the fixture is throwaway
  local desired=" keep-valid stale-source "
  local link name
  for link in "$dir"/*; do
    [ -L "$link" ] || continue
    name="${link##*/}"
    case "$desired" in
    *" $name "*)
      if [ -e "$link" ]; then
        continue
      fi
      ;;
    esac
    rm "$link"
  done

  [ -L "$dir/keep-valid" ] || fail "prune removed a valid in-set symlink"
  [ ! -L "$dir/stale-source" ] || fail "prune kept a symlink whose source is gone"
  [ ! -L "$dir/dropped-name" ] || fail "prune kept a symlink no longer in the desired set"
}

# bats test_tags=skills,opkg
@test "opkg: copy_is_subset gates autofix on recoverable content" {
  local src="$BATS_TEST_TMPDIR/src"
  mkdir -p "$src"
  : >"$src/SKILL.md"

  # Mirror copy_is_subset from run_onchange_after_publish-opkg.sh.tmpl
  copy_is_subset() {
    [ -d "$1" ] || return 1
    local extra
    extra=$(cd "$1" && find . \( -type f -o -type l \) | while IFS= read -r f; do
      [ -e "$2/$f" ] || echo "$f"
    done)
    [ -z "$extra" ]
  }

  local stale="$BATS_TEST_TMPDIR/stale"
  mkdir -p "$stale"
  : >"$stale/SKILL.md"
  run copy_is_subset "$stale" "$src"
  [ "$status" -eq 0 ] || fail "subset copy not deemed recoverable"

  local unique="$BATS_TEST_TMPDIR/unique"
  mkdir -p "$unique"
  : >"$unique/EXTRA.md"
  run copy_is_subset "$unique" "$src"
  [ "$status" -ne 0 ] || fail "copy with unique file wrongly deemed recoverable"

  run copy_is_subset "$src/SKILL.md" "$src"
  [ "$status" -ne 0 ] || fail "non-directory wrongly deemed a recoverable copy"
}
