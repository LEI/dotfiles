#!/bin/bash

set -euo pipefail

# Required on debian/ubuntu if /usr/bin/yq is present
if [ -x /home/linuxbrew/.linuxbrew/bin/brew ] && ! command -v brew >/dev/null; then
  PATH="$PATH:/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin"
fi

if [ -f /etc/arch-release ] && { [ -f /.dockerenv ] || [ -f /run/.containerenv ]; }; then
  mise reshim # shims point to stale mise path after pacman updates
fi

mise_doctor() {
  mise doctor --json | yq --colors --prettyPrint '.errors[], .warnings[]'
}

if [ "${CI:-}" = true ]; then
  mise_doctor || echo "WARN: mise doctor exited with code $?" >&2
else
  mise_doctor
fi
