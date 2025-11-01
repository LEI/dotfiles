#!/bin/sh

set -eu

# https://github.com/davatorium/rofi/discussions/1862

config=
file="${XDG_CONFIG_HOME:-$HOME/.config}/rofi/window.rasi"

if [ -f "$file" ]; then
  config="-config=$file"
fi

rofi "$config" -show window \
  -kb-accept-entry "!Alt-Tab,!Alt+Alt_L,Alt-Return,Return" \
  -kb-row-down Alt+Tab,Alt+Down,Down,Control+n \
  -kb-row-up Alt+ISO_Left_Tab,Alt+Up,Up,Control+p \
  -selected-row 1
