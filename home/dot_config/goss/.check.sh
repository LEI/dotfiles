#!/bin/sh

set -eu

export GOSS_USE_ALPHA=1

cd "${XDG_CONFIG_HOME:-$HOME/.config}/goss"

if [ "$#" -eq 0 ]; then
  set -- validate \
    --format=documentation \
    --format-options=sort \
    --retry-timeout=60s \
    --sleep=10s \
    "$@"
fi

if [ -f vars.yaml ]; then
  set -- --vars=vars.yaml "$@"
fi

set -- goss "$@"

echo "$@" >&2
"$@"
