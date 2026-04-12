#!/bin/sh
set -eu

if [ -f /etc/arch-release ] && { [ -f /.dockerenv ] || [ -f /run/.containerenv ]; }; then
  mise reshim # shims point to stale mise path after pacman updates
fi
if [ "${CI:-}" = true ]; then
  mise doctor || echo "WARN: mise doctor exited with code $?" >&2
else
  mise doctor
fi
