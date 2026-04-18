#!/usr/bin/env bash

setup_bats() {
  if ! command -v bats >/dev/null; then
    echo >&2 "setup_suite: bats is required"
    exit 1
  fi
}

git_clone() {
  echo >&3 "# setup_suite: git clone $*"
  git clone --single-branch "$@" >&3
}

# Clone bats libs if not in test_helper
setup_bats_libs() {
  for d in ./test_helper/bats-mock ./test_helper/bats-assert \
    ./test_helper/bats-support ./test_helper/bats-file; do
    [ -d "$d" ] && continue
    needs_clone=true
    break
  done
  [ "${needs_clone:-false}" != true ] && return

  if ! command -v git >/dev/null; then
    echo >&2 "setup_suite: git is required"
    exit 1
  fi
  [ "${CI:-}" = true ] && git config --global advice.detachedHead false

  [ -d ./test_helper/bats-mock ] || git_clone --branch=v1 https://github.com/jasonkarns/bats-mock ./test_helper/bats-mock
  [ -d ./test_helper/bats-assert ] || git_clone --branch=v2.2.4 https://github.com/bats-core/bats-assert ./test_helper/bats-assert
  [ -d ./test_helper/bats-support ] || git_clone --branch=v0.3.0 https://github.com/bats-core/bats-support ./test_helper/bats-support
  [ -d ./test_helper/bats-file ] || git_clone --branch=v0.4.0 https://github.com/bats-core/bats-file ./test_helper/bats-file
}

setup_suite() {
  setup_bats
  bash --version | head -n1 >&3
  bats --version >&3
  chezmoi --version >&3

  bats_require_minimum_version 1.5.0

  setup_bats_libs

  # Build path: test_helper + system libs + test dir (allow override)
  if [ -z "${BATS_LIB_PATH:-}" ]; then
    local path="${PWD}/test_helper"
    [ -d /usr/lib/bats ] && path="$path:/usr/lib/bats"
    path="$path:$PWD/test"
    export BATS_LIB_PATH="$path"
  else
    export BATS_LIB_PATH
  fi

  echo >&3 "# setup_suite: BATS_LIB_PATH=$BATS_LIB_PATH"

  export TEST_TMPDIR="${TEST_TMPDIR:-$BATS_RUN_TMPDIR/out}"
  mkdir -p "$TEST_TMPDIR"/{.chezmoiscripts/{linux,windows},.local/bin}

  UNAME="$(uname -s)"
  export UNAME
}
