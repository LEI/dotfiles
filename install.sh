#!/usr/bin/env bash
# install.sh

# DOT_ROOT="${BASH_SOURCE[0]%/*}"
# [ -f "$DOT_ROOT" ] && DOT_ROOT=$(dirname "$DOT_ROOT")

cd $(dirname "${BASH_SOURCE[0]}")
DOT_ROOT=$(pwd -P)

source dot/bootstrap.sh "$@" && \
  printf "%s\r\n" "DONE" || \
  printf "%s\r\n" "ERROR $?"
