#!/usr/bin/env bash

_common_setup() {
  bats_load_library bats-support
  bats_load_library bats-assert
  bats_load_library bats-file
  bats_load_library bats-mock/stub.bash

  # Prevent non-interactive bash subprocesses from sourcing .bashrc,
  # which rebuilds PATH and shadows bats-mock stubs
  unset BASH_ENV
}
