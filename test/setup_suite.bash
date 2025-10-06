#!/usr/bin/env bash

setup_suite() {
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
