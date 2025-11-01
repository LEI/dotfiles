#!/usr/bin/env bash

_common_setup() {
  # load "${BATS_LIB_PATH}/bats-support/load"
  # load "${BATS_LIB_PATH}/bats-assert/load"
  # load "${BATS_LIB_PATH}/bats-file/load"
  bats_load_library bats-support
  bats_load_library bats-assert
  bats_load_library bats-file
  bats_load_library bats-mock/stub.bash

  # bats_load_safe bats-mock/stub
  # load "${BATS_LIB_PATH##*:}/libs/bats-mock/stub"

  # bats_load_safe libs/bats-mock/stub
  # load "${BATS_LIB_PATH##*:}/bats-mock/stub"

  # Get the containing directory of this file
  # use $BATS_TEST_FILENAME instead of ${BASH_SOURCE[0]} or $0,
  # as those will point to the bats executable's location or the preprocessed file respectively
  # DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" >/dev/null 2>&1 && pwd)"
  # Make executables in src/ visible to PATH
  # PATH="$DIR/../src:$PATH"
}
