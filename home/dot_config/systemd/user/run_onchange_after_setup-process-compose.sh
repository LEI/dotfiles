#!/bin/bash
set -euo pipefail

. "$CHEZMOI_WORKING_TREE/home/.chezmoitemplates/helpers.sh"

if ! has process-compose; then
  err "process-compose not found"
fi

if has systemctl; then
  if ! systemctl --user is-active --quiet process-compose; then
    run systemctl --user enable --now process-compose
  else
    run systemctl --user restart process-compose
  fi
fi
