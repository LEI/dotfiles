#!/bin/sh
#MISE description="Run mise doctor"

set -eu

if [ -f /etc/arch-release ] && { [ -f /.dockerenv ] || [ -f /run/.containerenv ]; }; then
  mise reshim # shims point to stale mise path after pacman updates
fi
if [ "${CI:-}" = true ]; then
  mise doctor || echo >&2 "WARN: mise doctor exited with code $?"
else
  mise doctor
fi
