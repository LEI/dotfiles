#!/bin/sh

set -eu

if [ -f /etc/arch-release ] && { [ -f /.dockerenv ] || [ -f /run/.containerenv ]; }; then
  mise reshim # shims point to stale mise path after pacman updates
fi

# FIXME: jq: error (at <stdin>:130): Cannot iterate over null (null)
# mise doctor --json | jq --raw-output '.warnings[]'
if [ "${CI:-}" = true ]; then
  mise doctor || echo "WARN: mise doctor exited with code $?" >&2
else
  mise doctor
fi
