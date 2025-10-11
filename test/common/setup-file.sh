#!/usr/bin/env bash

_common_setup_file() {
  # Fixes failures when creating file in newly created directories
  # e.g. chezmoi cat >file in test/common/helper.sh
  export BATS_TEST_RETRIES=1

  # export SUDO_ASKPASS=false

  # chezmoi feature enabled --output=text >"$BATS_RUN_TMPDIR/chezmoi-features.txt"
}
