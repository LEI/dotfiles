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
  echo "$path"
}

setup_bats() {
  if ! command -v bats >/dev/null; then
    # run apk add --no-cache bats # bats-assert bats-support bats-file
    echo >&2 "setup_suite: bats is required"
    exit 1
  fi
}

git_clone() {
  echo >&3 "# setup_suite: git clone $*"
  git clone --single-branch "$@" >&3
}

# Clone libs unless installed with brew and except bats-mock on archlinux
setup_bats_libs() {
  # local pacman=false
  # if command -v pacman >/dev/null; then
  #   pacman=true
  # fi
  # if [ -z "$pacman" ] && command -v brew >/dev/null; then
  #   return
  # fi
  if ! command -v git >/dev/null; then
    # run apk add --no-cache git
    echo >&2 "setup_suite: git is required"
    exit 1
  fi
  if [ "${CI:-}" = true ]; then
    git config --global advice.detachedHead false
  fi
  if ! [ -d ./test_helper/bats-mock ]; then
    git_clone --branch=v1 https://github.com/jasonkarns/bats-mock \
      ./test_helper/bats-mock
  fi
  # if [ "$pacman" = true ]; then
  #   return
  # fi
  if ! [ -d ./test_helper/bats-assert ]; then
    git_clone --branch=v2.2.4 https://github.com/bats-core/bats-assert \
      ./test_helper/bats-assert
  fi
  if ! [ -d ./test_helper/bats-support ]; then
    git_clone --branch=v0.3.0 https://github.com/bats-core/bats-support \
      ./test_helper/bats-support
  fi
  if ! [ -d ./test_helper/bats-file ]; then
    git_clone --branch=v0.4.0 https://github.com/bats-core/bats-file \
      ./test_helper/bats-file
  fi
}

setup_suite() {
  setup_bats
  bats --version >&3
  chezmoi --version >&3

  # BW02: allow using flags on `run`
  bats_require_minimum_version 1.5.0

  # TODO: renovate and checkout new versions
  # rm -fr test_helper/*
  setup_bats_libs

  # BATS_LIB_PATH="$PWD/test_helper:$(get_bats_lib_path)"
  BATS_LIB_PATH="$PWD/test_helper:$(get_bats_lib_path)"
  echo >&3 "# setup_suite: BATS_LIB_PATH=$BATS_LIB_PATH"
  export BATS_LIB_PATH

  export TEST_TMPDIR="${TEST_TMPDIR:-$BATS_RUN_TMPDIR/out}"

  if ! [ -d "$TEST_TMPDIR" ]; then
    local dirs=()
    for d in "$TEST_TMPDIR/"{,.chezmoiscripts/{linux,windows},.local/bin}; do
      dirs+=("$d")
    done
    echo >&3 "# setup_suite: creating missing directories in $TEST_TMPDIR"
    # echo >&3 "# mkdir -p ${dirs[*]}"
    mkdir -p "${dirs[@]}"
  fi

  UNAME="$(uname -s)"
  export UNAME

  local tmp_bin="${TMPDIR:-/tmp}/bin"
  if [ -d "$tmp_bin" ] && [ -n "$(find "$tmp_bin" -type f)" ]; then
    echo >&3 "# WARN: $tmp_bin exists and is not empty, cleanup if stubs misbehave"
  fi
}

# teardown_suite() {}
