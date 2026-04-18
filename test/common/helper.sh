#!/usr/bin/env bash

source_container() {
  export CONTAINER_PROVIDER=dummy
  source ./script/container
}

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
    # Use chezmoi cat from the target path (HOME-relative)
    if ! chezmoi cat --no-tty --refresh-externals=never "$HOME/$script" >"$file" 2>&3; then
      fail "run_chezmoi: chezmoi cat failed for $script"
    elif ! [ -s "$file" ]; then
      fail "run_chezmoi: empty file: $script"
    fi
  fi

  run_script "$TEST_TMPDIR/$script" "$@"
}

# Get file permissions as octal (cross-platform)
file_perms() {
  if [ "$(uname -s)" = Darwin ]; then
    stat -f '%A' "$1"
  else
    stat -c '%a' "$1"
  fi
}

# Assert all files matching a glob have expected permissions
# Usage: check_perms 600 ~/.config/secrets.d/*.conf
check_perms() {
  local expected="$1"
  shift
  local bad=()
  for f in "$@"; do
    [ -e "$f" ] || continue
    local perm
    perm=$(file_perms "$f")
    if [ "$perm" != "$expected" ]; then
      bad+=("$f:$perm")
    fi
  done
  if [ ${#bad[@]} -gt 0 ]; then
    fail "expected $expected: ${bad[*]}"
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
  shift
  if [[ "$file" = */executable_* ]]; then
    local name="${file##*/}"
    local tmp_dir
    tmp_dir="$(mktemp -d)"
    local tmp_file="$tmp_dir/${name#executable_}"
    cat >"$tmp_file" <"$file"
  fi
  set -- "${tmp_file:-$file}" "$@"
  run --separate-stderr run_src "$@"
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
