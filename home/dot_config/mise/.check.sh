#!/bin/bash

set -euo pipefail

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
