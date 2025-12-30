#!/usr/bin/env bash

has_feature() {
  local name="$1"
  # local cmd="${1##* }"
  # case "$name" in
  # bottom) cmd=btm ;;
  # helix) cmd=hx ;;
  # neovim) cmd=nvim ;;
  # nushell) cmd=nu ;;
  # python) cmd=uv ;;
  # ripgrep) cmd=rg ;;
  # rust) cmd=cargo ;;
  # esac
  # command -v "$cmd" >/dev/null || skip "$* feature: $cmd not found"
  local feature
  feature="$(jq ".$name == true" "$HOME/.local/share/features.json")"
  if [ "$feature" = false ]; then
    # echo >&3 "# has_feature: feature disabled: $name"
    return 1
  fi
  if [ "$feature" != true ]; then
    # echo >&3 "# has_feature: unknown value: $name ($feature)"
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

  # BATS_SUITE_TMPDIR
  # BATS_TEST_TMPDIR

  if [ -z "$TEST_TMPDIR" ]; then
    fail "TEST_TMPDIR must be set"
  fi

  # local dirname file="$TEST_TMPDIR/$script"
  # dirname="$(dirname "$file")"
  # if ! [ -d "$dirname" ]; then
  #   # echo >&2 "$BATS_TEST_NAME: missing directory: $dirname"
  #   # exit 1
  #   echo >&3 "# run_chezmoi: creating directory: $dirname"
  #   mkdir -p "$dirname"
  #   # WARN: mkdir followed by chezmoi cat >"$file"" always fails when jobs >3
  #   # without --no-parallelize-within-files and sleep >0.05
  #   sleep 0.1
  # fi

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

  # echo >&3 "# chezmoi cat --refresh-externals=never $HOME/$script | tee $file"
  # chezmoi cat --refresh-externals=never "$HOME/$script" | tee "$file"

  # || {
  #   if [ $# != 0 ]; then
  #     echo >&3 "# run_chezmoi: failed to redirect command to file:"
  #     echo >&3 "# chezmoi cat --refresh-externals=never $HOME/$script >$file"
  #   fi
  #   fail "run_chezmoi: failed with exit code $#"
  #   exit "$#"
  # }

  # if ! chezmoi cat --refresh-externals=never "$HOME/$script" >"$file"; then
  #   # local cmd="chezmoi cat $HOME/$script >$file"
  #   echo >&3 "# run_chezmoi: retrying command (exit code $?) after creating: $dir"
  #   if ! chezmoi cat --refresh-externals=never "$HOME/$script" >"$file"; then
  #     echo >&3 "# run_chezmoi: failed command (exit code $?) after creating: $dir"
  #     exit 1
  #   fi
  # fi

  # chezmoi cat --refresh-externals=never "$HOME/$script" | tee "$file"

  # CHEZMOI_WORKING_TREE=. DRY_RUN=true
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

# _is_first_run() {
#   local FIRST_RUN_FILE=${1-/tmp/bats-tutorial-project-ran}
#   if [[ ! -e "$FIRST_RUN_FILE" ]]; then
#     touch "$FIRST_RUN_FILE"
#     return 0
#   fi
#   return 1
# }
