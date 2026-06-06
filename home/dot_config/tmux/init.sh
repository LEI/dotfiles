# shellcheck shell=bash

tmux() {
  TERM=tmux-256color command tmux "$@"
}

# Attach to named session or create it; runs optional command inside
# Usage: tmux-session [name] [command...]
tmux-session() {
  local name="${1:-${TMUX_SESSION:-$(basename "$PWD")}}"
  [ $# -gt 0 ] && shift
  tmux new-session -As "$name" "$@"
}
