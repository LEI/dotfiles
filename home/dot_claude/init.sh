# Resume last session by default
claude() {
  if [ $# -eq 0 ]; then
    set -- --continue
  fi
  command claude "$@"
}

alias claudes=claude_sessions
alias claudet=claude_teams
alias claudett=claude_teams_tmux

claude_resume() {
  local session_id
  session_id="$(basename "$PWD")"
  command claude --resume="$session_id" "$@"
}

# Browse project sessions via cc-sessions
claude_sessions() {
  if ! command -v cc-sessions >/dev/null; then
    echo >&2 "cc-sessions not installed"
    return 1
  fi
  if [ $# -eq 0 ] && [ -t 0 ]; then
    set -- --count=100 --include-forks --list --min-turns=0
  fi
  local project
  project="$(basename "$PWD")"
  cc-sessions "$@" --project="$project"
}

# Named task list using directory basename
# Override: CLAUDE_CODE_TASK_LIST_ID=custom claude_task
claude_task() {
  local task_list_id="${CLAUDE_CODE_TASK_LIST_ID:-$(basename "$PWD")}"
  CLAUDE_CODE_TASK_LIST_ID="$task_list_id" claude "$@"
}

# Teammate mode (auto detects tmux vs iTerm2)
claude_teams() {
  if [ $# -eq 0 ]; then
    set -- --continue
  fi
  command claude --teammate-mode=auto "$@"
}

# Teams in a tmux session using directory basename
# Override: TMUX_SESSION=custom claude_teams_tmux
claude_teams_tmux() {
  if ! type tmux_session >/dev/null 2>&1; then
    echo >&2 "tmux_session not defined; source tmux/init.sh"
    return 1
  fi
  local session_name="${TMUX_SESSION:-$(basename "$PWD")}"
  tmux_session "$session_name" claude --teammate-mode=tmux "$@"
}
