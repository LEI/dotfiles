#!/usr/bin/env bash

check_feature() {
  local name="$1"
  local cmd="${1##* }"
  case "$name" in
  python) cmd=uv ;;
  rust) cmd=cargo ;;
  esac
  command -v "$cmd" >/dev/null || skip "feature disabled: $* ($cmd not found)"
  # chezmoi feature "$name" ||
  # grep -qx "$name" "$BATS_RUN_TMPDIR/chezmoi-features.txt" ||
  # grep -q "\"$name\": true" "$HOME/.local/share/features.json" ||
  #   skip "feature disabled: $*"
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
    echo >&3 "# mkdir -p" "$dir"
  fi

  chezmoi cat --refresh-externals=never "$HOME/$script" >"$file"
  # || {
  #   if [ $# != 0 ]; then
  #     echo >&3 "# run_chezmoi: failed to redirect command to file:"
  #     echo >&3 "# chezmoi cat --refresh-externals=never $HOME/$script >$file"
  #   fi
  #   # fail "run_chezmoi: failed with exit code $#"
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
  run --separate-stderr \
    bash "$TEST_TMPDIR/$script" "$@"
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
    'echo >&3 "'"WARN: $BATS_TEST_NAME requires at least one more stub ($max + 1): $name"' $*"' \
    'exit 2'
}

# _is_first_run() {
#   local FIRST_RUN_FILE=${1-/tmp/bats-tutorial-project-ran}
#   if [[ ! -e "$FIRST_RUN_FILE" ]]; then
#     touch "$FIRST_RUN_FILE"
#     return 0
#   fi
#   return 1
# }
