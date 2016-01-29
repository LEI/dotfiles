#!/bin/bash
# install.sh

# DOT_ROOT="${BASH_SOURCE[0]%/*}"
# [ -f "$DOT_ROOT" ] && DOT_ROOT=$(dirname "$DOT_ROOT")

cd $(dirname "${BASH_SOURCE[0]}")
DOT_ROOT=$(pwd -P)

source dot/bootstrap.sh "$@" && echo "BOOTSTRAP:OK" || echo "BOOTSTRAP:ERR"
