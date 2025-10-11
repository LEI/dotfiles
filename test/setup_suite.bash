#!/usr/bin/env bash

get_bats_lib_path() {
  local path="${BATS_LIB_PATH:-}"
  if [ -n "$path" ] && { [[ "$path" = *:* ]] || [ -d "$path" ]; }; then
    :
  elif [ "$UNAME" = Darwin ] || command -v brew >/dev/null; then
    path="$(brew --prefix)/lib"
  elif [ "$path" != /usr/lib/bats ] && [ -d /usr/lib/bats ]; then
    path=/usr/lib/bats
  else
    path=/usr/lib
  fi
  echo >&3 "# setup suite: changed BATS_LIB_PATH=$BATS_LIB_PATH"
  echo "$path"
}

setup_suite() {
  # BW02: allow using flags on `run`
  bats_require_minimum_version 1.5.0

  echo >&3 "# setup suite: BATS_LIB_PATH=$BATS_LIB_PATH"
  BATS_LIB_PATH="$(get_bats_lib_path)"
  export BATS_LIB_PATH

  export TEST_TMPDIR="${TEST_TMPDIR:-$BATS_RUN_TMPDIR/out}"

  if ! [ -d "$TEST_TMPDIR" ]; then
    local dirs=()
    for d in "$TEST_TMPDIR/"{,.chezmoiscripts/{,linux,windows},.local/bin}; do
      dirs+=("$d")
    done
    echo >&3 "# setup_suite: creating missing directories in $TEST_TMPDIR"
    # echo >&3 "# mkdir -p ${dirs[*]}"
    mkdir -p "${dirs[@]}"
  fi

  UNAME="$(uname -s)"
  export UNAME
}

# teardown_suite() {}
