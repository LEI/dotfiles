#!/bin/sh

set -eu

# TODO: detect mise installation method
mise="$(command -v mise 2>/dev/null)"
if [ "$mise" != "$HOME/.local/bin/mise" ]; then
  echo >&2 "update: skipping mise self-update: not in in $HOME/.local/bin/mise"
  exit
fi

set -x

timeout 5m mise self-update --yes
