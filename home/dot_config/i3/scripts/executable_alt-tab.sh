#!/bin/sh

set -eu

# https://github.com/davatorium/rofi/discussions/1862

rofi \
  -auto-select \
  -show window \
  -timeout-delay 5 \
  -timeout-action "kb-accept-entry" \
  -kb-accept-entry "Return"
