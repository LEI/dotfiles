#!/bin/sh

# Resume last session by default
claude() {
  if [ $# -eq 0 ]; then
    set -- --resume "$(basename "$PWD")"
  fi
  env claude "$@"
}

# Launch claude in a named tmux session
claude_tmux() {
  project="$(basename "$PWD")"
  if [ $# -eq 0 ]; then
    set -- --resume "$project"
  fi
  tmux new-session -As "$project" claude "$@"
}

# export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
# TEAMMATE_MODE: tmux (default), in-process, auto
claude_teams() {
  TEAMMATE_MODE="${TEAMMATE_MODE:-tmux}"
  claude_tmux --teammate-mode="$TEAMMATE_MODE" "$@"
}

claude_sessions() {
  if [ $# -eq 0 ]; then
    if [ -t 0 ]; then
      set -- --count=100 --include-forks --list --min-turns=0 "$@"
    fi
    project="$(basename "$PWD")"
    set -- --project="$project"
  fi
  env cc-sessions "$@"
}
