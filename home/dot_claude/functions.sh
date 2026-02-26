#!/bin/sh

# Resume last session by default
claude() {
  # export CLAUDE_CODE_TASK_LIST_ID="${CLAUDE_CODE_TASK_LIST_ID:-$(basename "$PWD")}"
  if [ $# -eq 0 ]; then
    set -- --continue
  fi

  # https://code.claude.com/docs/en/memory#load-memory-from-additional-directories
  # export CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1
  # set -- "$@" --additional-directories="$XDG_DATA_HOME/memory"

  env claude "$@"
}

# Launch claude in a named tmux session
claude_tmux() {
  project="$(basename "$PWD")"
  # if [ $# -eq 0 ]; then
  #   set -- --resume "$project"
  # fi
  TMUX_SESSION_NAME="${TMUX_SESSION_NAME:-$project}"
  tmux new-session -As "$TMUX_SESSION_NAME" claude "$@"
}

# export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
# TEAMMATE_MODE: tmux (default), in-process, auto
claude_teams() {
  TEAMMATE_MODE="${TEAMMATE_MODE:-tmux}"
  claude_tmux --teammate-mode="$TEAMMATE_MODE" "$@"
}

cld() {
  if [ -t 1 ]; then
    nu ~/src/github.com/LEI/cld/cld.nu "$@"
  else
    # only inject -o table when no -o flag is explicitly provided
    case "$*" in
      *" -o "*|*" --output "*)
        nu ~/src/github.com/LEI/cld/cld.nu "$@" ;;
      *)
        nu ~/src/github.com/LEI/cld/cld.nu -o table "$@" ;;
    esac
  fi
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
