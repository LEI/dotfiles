#!/bin/sh

set -eu

# mise="$(command -v mise 2>/dev/null)"
# if [ "$mise" != "$HOME/.local/bin/mise" ]; then
#   echo "update: skipping mise self-update: not in in $HOME/.local/bin/mise" >&2
#   exit
# fi

# mise doctor | grep -qv 'self_update_available: yes'
if [ "$(mise doctor --json | jq .self_update_available)" != true ]; then
  echo "update: mise self-update not available" >&2
  exit
fi

set -x

timeout 5m mise self-update --yes
