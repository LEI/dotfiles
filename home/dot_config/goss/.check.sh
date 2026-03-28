#!/bin/sh
#MISE description="Validate system state with goss"

set -eu

export GOSS_USE_ALPHA=1
cd "${XDG_CONFIG_HOME:-$HOME/.config}/goss"
if [ "$#" -eq 0 ]; then
  set -- validate --format=documentation --retry-timeout=30s --sleep=5s "$@"
fi
exec goss --vars=vars.yaml "$@"
