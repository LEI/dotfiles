if hash t 2>/dev/null; then
  return
fi

# Attach to an existing session or create a new session
t() {
  if [ $# -ne 0 ]; then
    tmux "$@"
  elif [ "$*" = "-uNONE" ]; then
    tmux -f/dev/null -Ltmp lsk
  elif [ -n "${TMUX:-}" ]; then
    tmux new-session -d
  else
    tmux attach || tmux new-session
  fi
}
