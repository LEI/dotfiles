tmux() {
  TERM=tmux-256color command tmux "$@"
}

# Attach to named session or create it; runs optional command inside
# Usage: tmux_session [name] [command...]
# Default name: current directory basename
tmux_session() {
  local name="${1:-$(basename "$PWD")}"
  [ $# -gt 0 ] && shift
  tmux new-session -As "$name" "$@"
}
