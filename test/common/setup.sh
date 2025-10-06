#!/usr/bin/env bash

_common_setup() {
  # BW02: allow using flags on `run`
  bats_require_minimum_version 1.5.0

  # if [ "$UNAME" = Darwin ]; then
  BATS_LIB_PATH="$(brew --prefix)/lib"
  # elif [ -d /usr/lib/bats ]; then
  #   BATS_LIB_PATH=/usr/lib/bats
  # else
  #   BATS_LIB_PATH=/usr/lib
  # fi
  export BATS_LIB_PATH

  # load "${BATS_LIB_PATH}/bats-support/load"
  # load "${BATS_LIB_PATH}/bats-assert/load"

  bats_load_library bats-support
  bats_load_library bats-assert

  load "${BATS_LIB_PATH}/bats-mock/stub"

  # Get the containing directory of this file
  # use $BATS_TEST_FILENAME instead of ${BASH_SOURCE[0]} or $0,
  # as those will point to the bats executable's location or the preprocessed file respectively
  # DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" >/dev/null 2>&1 && pwd)"
  # Make executables in src/ visible to PATH
  # PATH="$DIR/../src:$PATH"
}
