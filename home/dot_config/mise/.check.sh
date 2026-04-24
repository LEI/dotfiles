#!/bin/bash

set -euo pipefail

# Required on debian/ubuntu if /usr/bin/yq is present
if [ -x /home/linuxbrew/.linuxbrew/bin/brew ] && ! command -v brew >/dev/null; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# Activate mise if not already active (sets MISE_SHELL and prepends shims to PATH)
if [ -z "${MISE_SHELL:-}" ] && command -v mise >/dev/null; then
  eval "$(mise activate bash)"
fi

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
