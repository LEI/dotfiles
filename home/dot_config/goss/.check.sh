#!/bin/sh
set -eu

export GOSS_USE_ALPHA=1
cd "${XDG_CONFIG_HOME:-$HOME/.config}/goss"
if [ "$#" -eq 0 ]; then
  # Format options per formatter (via --format-options or $GOSS_FMT_OPTIONS):
  #   documentation: sort
  #   json/structured: pretty, sort
  #   nagios: perfdata, verbose
  #   prometheus: verbose
  set -- validate \
    --format=documentation \
    --format-options=sort \
    --retry-timeout=10s \
    --sleep=5s \
    "$@"
fi
echo >&2 "goss --vars=vars.yaml $*"
exec goss --vars=vars.yaml "$@"
