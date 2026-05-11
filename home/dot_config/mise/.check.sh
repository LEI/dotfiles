#!/bin/bash

set -euo pipefail

# Required for yq on debian
if [ -x /home/linuxbrew/.linuxbrew/bin/brew ] && ! command -v brew >/dev/null; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# FIXME: unused shims are present, run mise reshim to remove them
mise reshim

exit_code=0
mise doctor --json | yq --colors --prettyPrint '.errors[], .warnings[]' || exit_code=$?

if [ $exit_code -eq 1 ]; then
  echo "WARN: mise doctor exited with code $exit_code" >&2
elif [ $exit_code -gt 0 ]; then
  echo "ERROR: mise doctor exited with code $exit_code" >&2
  exit $exit_code
fi
