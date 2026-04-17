#!/bin/bash

set -euo pipefail

# Required on debian/ubuntu if /usr/bin/yq is present
if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

if [ -f /etc/arch-release ] && { [ -f /.dockerenv ] || [ -f /run/.containerenv ]; }; then
  mise reshim # shims point to stale mise path after pacman updates
fi

mise_doctor() {
  mise doctor --json | yq --colors --prettyPrint '.warnings[]'
  # jq --raw-output '.warnings[]'
}

if [ "${CI:-}" = true ]; then
  mise_doctor || echo "WARN: mise doctor exited with code $?" >&2
else
  mise_doctor
fi
