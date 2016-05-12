# Tmux

t() {
  if [[ "$#" -eq 0 ]]; then
    tmux attach || tmux new-session
  else
    tmux "$@"
  fi
}
