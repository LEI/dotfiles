#!/bin/bash

# Usage:
#   oage ps --all
#   oage up --build --detach
#   oage logs --follow --since=1m
#   oage down

export OAGE_CONFIG_DIR="${OAGE_CONFIG_DIR:-$HOME/.config/oage}"
export OAGE_PROVIDER="${OAGE_PROVIDER:-docker}" # Container provider
# systemctl --user start podman.socket

run() {
  echo >&2 "+ $*"
  "$@"
}

oage_compose() {
  run $OAGE_PROVIDER compose --project-directory="$OAGE_CONFIG_DIR" "$@"
}

oage() {
  if [ $# -eq 0 ]; then
    oage_compose up --build --detach
    set -- logs --follow --since=1m
  fi
  oage_compose "$@"
}
