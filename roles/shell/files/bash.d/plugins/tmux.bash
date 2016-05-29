# Tmux

t() {
  if [[ $# -gt 0 ]]; then
    tmux "$@"
  else
    # tmux list-sessions
    tmux attach || tmux new-session
  fi
}

# Attach or create tmux session named the same as current directory
# https://github.com/thoughtbot/dotfiles/blob/master/bin/tat

tat() {
  local path_name="$(basename "$PWD" | tr . -)"
  local session_name=${1-$path_name}

  if [[ -z "$TMUX" ]]; then
    # Not in Tmux
    tmux new-session -As "$session_name"
  else
    if ! session_exists "$session_name"; then
      create_detached_session "$session_name"
    fi
    tmux switch-client -t "$session_name"
  fi
}

session_exists() {
  tmux list-sessions | sed -E 's/:.*$//' | grep -q "^$1$"
}

create_detached_session() {
  (TMUX='' tmux new-session -Ad -s "$1")
}
