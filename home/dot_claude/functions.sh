#!/bin/sh

# Resume last session by default
claude() {
  if [ $# -eq 0 ]; then
    set -- --continue
  fi
  # https://code.claude.com/docs/en/memory#load-memory-from-additional-directories
  # export CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1
  # set -- "$@" --add-dir "$XDG_DATA_HOME/memory"
  env claude "$@"
}

# Launch claude in a named tmux session
claude_tmux() {
  TMUX_SESSION_NAME="${TMUX_SESSION_NAME:-$(basename "$PWD")}"
  tmux new-session -As "$TMUX_SESSION_NAME" claude "$@"
}

# TEAMMATE_MODE: tmux (default), in-process, auto
# Requires CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 in environment
claude_teams() {
  TEAMMATE_MODE="${TEAMMATE_MODE:-tmux}"
  claude_tmux --teammate-mode="$TEAMMATE_MODE" "$@"
}

# Launch claude with task list ID set to current directory name
claude_task() {
  CLAUDE_CODE_TASK_LIST_ID="${CLAUDE_CODE_TASK_LIST_ID:-$(basename "$PWD")}" claude "$@"
}

claude_sessions() {
  if ! command -v cc-sessions > /dev/null; then
    echo >&2 "cc-sessions not installed"
    return 1
  fi
  if [ $# -eq 0 ]; then
    if [ -t 0 ]; then
      set -- --count=100 --include-forks --list --min-turns=0
    fi
    set -- "$@" --project="$(basename "$PWD")"
  fi
  env cc-sessions "$@"
}
