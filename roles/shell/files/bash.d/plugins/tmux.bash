# Tmux

t() {
  if [[ "$#" -eq 0 ]]; then
    # Try to attach or create a new session
    tmux attach || tmux new-session
  else
    tmux "$@"
  fi
}
