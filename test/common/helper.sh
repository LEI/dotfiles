#!/usr/bin/env bash

has_feature() {
  local name="$1"
  local feature
  feature="$(jq ".$name == true" "$HOME/.local/state/chezmoi/features.json")"
  if [ "$feature" = false ]; then
    return 1
  fi
  if [ "$feature" != true ]; then
    return 2
  fi
  if [ -n "${DEBUG-}" ]; then
    echo >&3 "# DEBUG has_feature: feature enabled: $name"
  fi
}

check_feature() {
  local name="$1"
  if ! has_feature "$name"; then
    skip "feature disabled: $name"
  fi
}

check_command() {
  for command in "$@"; do
    command -v "$command" >/dev/null || skip "$command not found"
  done
}

run_chezmoi() {
  local script="$1"
  shift

  if [ -z "$TEST_TMPDIR" ]; then
    fail "TEST_TMPDIR must be set"
  fi

  local file="$TEST_TMPDIR/$script"
  local dir="${file%/*}"
  if ! [ -d "$dir" ]; then
    echo >&3 "# WARN: missing directory $dir"
  fi

  # Skip rendering if already pre-rendered (e.g. by chezmoi-render in coverage)
  if ! [ -s "$file" ]; then
    # Shared persistent state to avoid lock contention across test files
    local persistent_state="$TEST_TMPDIR/chezmoi-state.json"

    # Use chezmoi cat from the target path (HOME-relative)
    if ! chezmoi cat --no-tty --persistent-state="$persistent_state" --refresh-externals=never "$HOME/$script" >"$file" 2>&3; then
      fail "run_chezmoi: chezmoi cat failed for $script"
    elif ! [ -s "$file" ]; then
      fail "run_chezmoi: empty file: $script"
    fi
  fi

  run_script "$TEST_TMPDIR/$script" "$@"
}

# TODO: lib/sh
if stat --version >/dev/null 2>&1; then
  file_perms() {
    stat -c '%a' "$1"
  }
  file_perms_fmt() {
    stat -c '%A' "$1"
  }
else
  file_perms() {
    stat -f '%A' "$1"
  }
  file_perms_fmt() {
    stat -f '%Sp' "$1"
  }
fi

# Assert all files matching a glob have expected permissions
# Usage: check_perms 600 ~/.config/secrets.d/*.conf
check_perms() {
  local expected="$1"
  shift
  local fix=()
  for file in "$@"; do
    [ -e "$file" ] || continue
    local perm
    perm=$(file_perms "$file")
    if [ "$perm" != "$expected" ]; then
      stat="$(file_perms_fmt "$file")"
      fix+=("$stat # expected: chmod $expected ${file/$HOME/\~}")
    fi
  done
  if [ ${#fix[@]} -gt 0 ]; then
    local IFS=$'\n'
    # fail "expected $expected:"$'\n'"${fix[*]}"
    fail $'\n'"${fix[*]}"
  fi
}

# Source a script with correct $0 and positional params.
# Runs in the caller's process so kcov can track coverage.
run_src() {
  local script="$1"
  shift
  if ! [ -f "$script" ]; then
    echo >&2 "run_src: file not found: $script"
    return 127
  fi
  # Not local: BASH_ARGV0 must be global to set $0
  BASH_ARGV0="$script"
  # shellcheck disable=SC1090
  source "$script" "$@"
}

# Run a script with stderr separation
run_script() {
  local file="$1"
  local tmp_file=""
  shift
  if [[ "$file" = */executable_* ]]; then
    local name="${file##*/}"
    local tmp_dir
    tmp_dir="$(mktemp -d "$BATS_TEST_TMPDIR/XXXXXX")"
    tmp_file="$tmp_dir/${name#executable_}"
    cat >"$tmp_file" <"$file"
  fi
  set -- "${tmp_file:-$file}" "$@"
  run --separate-stderr run_src "$@"
}

exclude_under_symlink() {
  local line d skip
  while IFS= read -r line; do
    [ -n "$line" ] || continue
    d="$line"
    skip=
    while :; do
      d="${d%/*}"
      case "$d" in "" | "$HOME" | "/") break ;; esac
      if [ -L "$d" ]; then
        skip=1
        break
      fi
    done
    [ -z "$skip" ] && printf '%s\n' "$line"
  done
  return 0
}

no_unmanaged() {
  local path="$1"
  [ -d "$path" ] || skip "not present: $path"
  run --separate-stderr chezmoi unmanaged --no-tty --refresh-externals=never \
    --persistent-state="$BATS_TEST_TMPDIR/chezmoi-state.boltdb" "$path"
  assert_success
  refute_output
}

# Assert each directory plugin's install cache matches its deployed source.
# Plugins deployed at <base>/<mkt>/plugins/<plugin>/ are copied to
# <base>/cache/<mkt>/<plugin>/<version>/ at install time. chezmoi apply does not
# refresh that cache, so a renamed or edited file keeps running stale until the
# plugin is reinstalled. Mirrors no_unmanaged: pass a base, it asserts.
assert_plugin_cache_fresh() {
  local base="$1"
  [ -d "$base/cache" ] || skip "no plugin cache: $base/cache"
  run plugin_cache_drift "$base"
  assert_success
  refute_output
}

# Print cache-vs-source drift for every directory plugin under a plugins base.
# No output means every cache copy matches its deployed source. Per stale plugin:
# a copy-pastable refresh command, then one labelled line per file (changed, missing
# from the cache, or orphaned in the cache), each relative to the plugin dir.
# Subshell body keeps nullglob local to the call.
plugin_cache_drift() (
  local base="$1" src cache mkt plugin id line name rel label report
  shopt -s nullglob
  for src in "$base"/*/plugins/*/; do
    src="${src%/}"
    [ -d "$src/.claude-plugin" ] || continue
    plugin="${src##*/}"
    mkt="${src%/plugins/*}" mkt="${mkt##*/}"
    id="$plugin@$mkt"
    for cache in "$base/cache/$mkt/$plugin"/*/; do
      cache="${cache%/}"
      report=""
      while IFS= read -r line; do
        case "$line" in
        "Files $src/"*)
          rel="${line#Files "$src"/}"
          report+="  changed: ${rel% and *}"$'\n'
          ;;
        "Only in $src"* | "Only in $cache"*)
          rel="${line#Only in }" name="${line##*: }" rel="${rel%: *}"
          case "$rel" in
          "$src"*) label=missing rel="${rel#"$src"}" ;;
          *) label=orphan rel="${rel#"$cache"}" ;;
          esac
          rel="${rel#/}"
          report+="  $label: ${rel:+$rel/}$name"$'\n'
          ;;
        esac
      done < <(diff --brief --recursive --exclude=.in_use --exclude=.DS_Store "$src" "$cache")
      [ -n "$report" ] || continue
      printf '%s: cache out of sync with deployed source, refresh with:\n' "$id"
      printf 'claude plugin uninstall %s && claude plugin install %s\n' "$id" "$id"
      printf '%s' "$report"
    done
  done
)

# Discover rule dirs by structural convention: dirs containing symlinks
# targeting */packages/*/rules. Agnostic to tool name.
discover_rule_dirs() {
  find "$HOME" -maxdepth 4 -type l -lname '*/packages/*/rules' 2>/dev/null |
    sed 's|/[^/]*$||' |
    sort -u
}

stub_seq() {
  local name="$1"
  shift
  local max=1
  if [ $# -gt 0 ]; then
    max="$1"
    shift
  fi
  plan=()
  for i in $(seq 1 "$max"); do
    plan+=('echo >&2 "# STUB '"$i: $name"' $*"')
  done
  stub "$name" "${plan[@]}" "$@" \
    'echo >&3 "'"WARN: $BATS_TEST_NAME extra stub, change to: stub_seq $name $((max + 1))"' $*"' \
    'exit 2'
  # shellcheck disable=SC2329
  bats::on_failure() {
    unstub "$name" 2>/dev/null || true
  }
}
