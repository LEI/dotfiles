setup() {
  # shellcheck source=test/common/setup.sh
  source test/common/setup.sh
  _common_setup

  # shellcheck source=test/common/helper.sh
  source test/common/helper.sh
}

# bats file_tags=home,type:smoke

@test "macos: script exists and is executable" {
  [ "$UNAME" = Darwin ] || skip "$UNAME"
  [ -x ~/.macos ]
}

# bats test_tags=secrets,permissions
@test "secrets.d: directory exists and is 700" {
  if [ ! -d "$HOME/.config/secrets.d" ]; then
    skip "secrets.d not present"
  fi
  check_perms 700 "$HOME/.config/secrets.d"
}

# bats test_tags=secrets,permissions
@test "secrets.d: files are private" {
  if ! compgen -G "$HOME/.config/secrets.d/*.conf" >/dev/null; then
    skip "no conf files yet"
  fi
  check_perms 600 "$HOME/.config/secrets.d"/*.conf
}

# NOTE: SSH config, config.d/*.conf and id_*.pub may be 644
# bats test_tags=ssh,permissions
@test "ssh: files are private" {
  check_feature ssh
  [ -d "$HOME/.ssh" ] || skip ".ssh not present"
  check_perms 700 "$HOME/.ssh"
  local -a files
  mapfile -d '' -t files < <(find "$HOME/.ssh" -maxdepth 2 -type f -not -name '*.pub' -print0 2>/dev/null)
  check_perms 600 "${files[@]}"
}

# bats test_tags=deploy,permissions
@test "local.yaml: files are private" {
  # local found=false
  # for f in ~/.logseq/local.yaml ~/.config/*/local.yaml ~/.claude/local.yaml; do
  #   [ -f "$f" ] || continue
  #   found=true
  # done
  # if ! $found; then
  #   skip "no local.yaml files"
  # fi
  local -a files
  mapfile -d '' -t files < <(find "$HOME" -maxdepth 2 -type f -name local.yaml -print0 2>/dev/null)
  [ ${#files[@]} -gt 0 ] || skip "no local.yaml files"
  check_perms 600 "${files[@]}"
}

# bats test_tags=deploy,validation
@test "environment.d: no unmanaged files" {
  [ -d "$HOME/.config/environment.d" ] || skip "environment.d not present"
  run --separate-stderr chezmoi unmanaged --no-tty --refresh-externals=never "$HOME/.config/environment.d"
  assert_success
  refute_output
}

# bats test_tags=deploy,validation
@test "secrets.d: no unmanaged files" {
  [ "${STRICT:-}" = true ] || skip "STRICT not set"
  [ -d "$HOME/.config/secrets.d" ] || skip "secrets.d not present"
  run --separate-stderr chezmoi unmanaged --no-tty --refresh-externals=never "$HOME/.config/secrets.d"
  assert_success
  refute_output
}

# Collect unique KEY= names from all .conf files in a directory
_conf_keys() {
  local dir="$1"
  if [ ! -d "$dir" ]; then
    return
  fi
  grep -h '^[A-Z_]*=' "$dir"/*.conf 2>/dev/null | cut -d= -f1 | sort -u
}

# bats test_tags=deploy,validation
@test "environment.d: no duplicate keys" {
  local dupes
  dupes=$(_conf_keys "$HOME/.config/environment.d" | uniq -d) || true
  if [ -n "$dupes" ]; then
    fail "duplicate keys in environment.d: $dupes"
  fi
}

# bats test_tags=secrets,validation
@test "secrets.d: no duplicate keys" {
  local dupes
  dupes=$(_conf_keys "$HOME/.config/secrets.d" | uniq -d) || true
  if [ -n "$dupes" ]; then
    fail "duplicate keys in secrets.d: $dupes"
  fi
}

# bats test_tags=secrets,deploy,validation
@test "environment.d and secrets.d: no key collisions" {
  local env_keys sec_keys
  env_keys=$(_conf_keys "$HOME/.config/environment.d")
  sec_keys=$(_conf_keys "$HOME/.config/secrets.d")
  if [ -z "$env_keys" ] || [ -z "$sec_keys" ]; then
    skip "need keys in both dirs"
  fi
  local dupes
  dupes=$(comm -12 <(echo "$env_keys") <(echo "$sec_keys")) || true
  if [ -n "$dupes" ]; then
    fail "key collision across environment.d and secrets.d: $dupes"
  fi
}
