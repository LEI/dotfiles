#!/bin/bash

set -euo pipefail

# Required on debian/ubuntu if /usr/bin/yq is present
if [ -x /home/linuxbrew/.linuxbrew/bin/brew ] && ! command -v brew >/dev/null; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# Ensure mise shims take precedence over brew paths, as in an interactive shell
shims="${XDG_DATA_HOME:-$HOME/.local/share}/mise/shims"
if [ -d "$shims" ]; then
  PATH="$shims:$PATH"
fi
unset shims

# if [ -f /etc/arch-release ] && { [ -f /.dockerenv ] || [ -f /run/.containerenv ]; }; then
#   mise reshim # shims point to stale mise path after pacman updates
# fi

mise_doctor() {
  mise doctor --json | yq --colors --prettyPrint '.warnings[]'
  # jq --raw-output '.warnings[]'
}

if [ "${CI:-}" = true ]; then
  mise_doctor || echo "WARN: mise doctor exited with code $?" >&2
else
  mise_doctor
fi
