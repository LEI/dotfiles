#!/usr/bin/env bash

_common_setup_file() {
  # FIXME: failures when creating file in newly created directories
  # e.g. chezmoi cat >file in test/common/helper.sh
  export BATS_TEST_RETRIES=0

  # export SUDO_ASKPASS=false

  chezmoi="$(command -v chezmoi)"
  export chezmoi

  # chezmoi feature enabled --output=text >"$BATS_RUN_TMPDIR/chezmoi-features.txt"
}
