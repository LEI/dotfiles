# shellcheck shell=sh

if [ -d "$HOME/.local/bin" ]; then
  pathmunge "$HOME/.local/bin" replace
fi
if [ -d "$HOME/bin" ]; then
  pathmunge "$HOME/bin" replace
fi
