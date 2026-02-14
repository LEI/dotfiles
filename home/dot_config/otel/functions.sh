#!/bin/bash

# Usage:
#   otel ps --all
#   otel up --build --detach
#   otel logs --follow --since=1m
#   otel down

export OTEL_CONFIG_DIR="${OTEL_CONFIG_DIR:-$HOME/.config/otel}"
export OTEL_PROVIDER="${OTEL_PROVIDER:-docker}" # Container provider
# systemctl --user start podman.socket

run() {
  echo >&2 "+ $*"
  "$@"
}

otel_compose() {
  run $OTEL_PROVIDER compose --project-directory="$OTEL_CONFIG_DIR" "$@"
}

otel() {
  if [ $# -eq 0 ]; then
    otel_compose up --build --detach
    set -- logs --follow --since=1m
  fi
  otel_compose "$@"
}
