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

  # shellcheck disable=SC2154
  "$chezmoi" cat --refresh-externals=never "$HOME/$script" >"$file"

  if ! [ -f "$file" ]; then
    echo >&3 "# run_chezmoi: failed to create file: $file"
    exit 2
  elif ! [ -s "$file" ]; then
    echo >&3 "# run_chezmoi: empty file: $file"
    exit 2
  fi

  run --separate-stderr bash "$TEST_TMPDIR/$script" "$@"
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
