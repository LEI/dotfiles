#!/bin/bash

set -eu

run() {
  echo >&2 "+ $*"
  "$@"
}

# FIXME: interactive prompt in case mise.toml exists
mise trust --all
# mise trust ~/.config/mise
# if test -f mise.toml; then
#   run mise trust --ignore
# fi

# Run the agent
if ! run pi --continue "$@"; then
  echo >&2 "exit code: $?"
fi

# Ensure the container keeps running
exec bash -i
