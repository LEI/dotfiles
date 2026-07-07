# shellcheck shell=bash

# Resume last session by default
claude() {
  if [ $# -eq 0 ]; then
    set -- --continue
  fi
  command claude "$@"
}

alias claudep=claude-plan

alias claudes=claude-sessions
alias claudet=claude-teams
alias claudett=claude-teams_tmux

claude-agents() {
  command claude agents --cwd .
}

claude-resume() {
  local session_id
  session_id="$(basename "$PWD")"
  command claude --resume="$session_id" "$@"
}

# Browse project sessions via cc-sessions
claude-sessions() {
  if ! command -v cc-sessions >/dev/null; then
    echo "cc-sessions not installed" >&2
    return 1
  fi
  # if [ $# -eq 0 ] && [ -t 0 ]; then
  #   set -- --count=100 --include-forks --list --min-turns=0
  # fi
  local project
  project="$(basename "$PWD")"
  cc-sessions "$@" --project="$project"
}

# Named task list using directory basename
# Override: CLAUDE_CODE_TASK_LIST_ID=custom claude-task
claude-task() {
  local task_list_id="${CLAUDE_CODE_TASK_LIST_ID:-$(basename "$PWD")}"
  CLAUDE_CODE_TASK_LIST_ID="$task_list_id" claude "$@"
}

# Teammate mode (auto detects tmux vs iTerm2)
claude-teams() {
  if [ $# -eq 0 ]; then
    set -- --continue
  fi
  command claude --teammate-mode=auto "$@"
}

# Teams in a tmux session using directory basename
# Usage: TMUX_SESSION=custom claude-teams-tmux
claude-teams-tmux() {
  if ! type tmux-session >/dev/null 2>&1; then
    echo "tmux-session not defined; source tmux/init.sh" >&2
    return 1
  fi
  local session_name="${TMUX_SESSION:-$(basename "$PWD")}"
  tmux-session "$session_name" claude --teammate-mode=tmux "$@"
}

# Active claude provider from CLAUDE_PROVIDER or ~/.claude/local.yaml, empty for native
claude-provider() {
  if [ -n "${CLAUDE_PROVIDER:-}" ]; then
    printf '%s\n' "$CLAUDE_PROVIDER"
    return
  fi
  local local_yaml="${HOME}/.claude/local.yaml"
  [ -f "$local_yaml" ] && yq -r '.provider // ""' "$local_yaml"
}

# Base URL for a provider, read from the chezmoi source data file
claude-provider-url() {
  local data
  data="$(chezmoi source-path)/dot_claude/.data.yaml"
  yq -r ".providers[\"$1\"].url // \"\"" "$data"
}

# Run a command under a provider's ANTHROPIC_* env, native when provider is empty
# Usage: claude-provider-exec PROVIDER CMD...
claude-provider-exec() {
  local provider="$1"
  shift
  if [ -n "$provider" ]; then
    local base_url key
    base_url=$(claude-provider-url "$provider")
    if [ -z "$base_url" ]; then
      echo "claude provider: no URL for '$provider'" >&2
      return 1
    fi
    key=$("${CLAUDE_CONFIG_DIR:-$HOME/.claude}/api-key-helper.sh" "$provider")
    if [ -z "$key" ]; then
      echo "claude provider: no API key for '$provider'" >&2
      return 1
    fi
    ANTHROPIC_BASE_URL="$base_url" ANTHROPIC_AUTH_TOKEN="$key" "$@"
    return
  fi
  "$@"
}

# Run claude --print under the active provider
claude-print() {
  claude-provider-exec "$(claude-provider)" command claude --print "$@"
}

check-ai() {
  local dir="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/plugins/cache/claude-dashboard/claude-dashboard"
  local scripts=("$dir"/*/dist/check-usage.js)
  local script="${scripts[-1]}"
  if [ ! -f "$script" ]; then
    echo "check-ai: claude-dashboard plugin not found" >&2
    return 1
  fi

  if command -v mise >/dev/null 2>&1; then
    set -- mise exec node@lts -- "$script" "$@"
  else
    set -- node "$script" "$@"
  fi

  claude-provider-exec "$(claude-provider)" "$@"
}

# # Pop Kitty keyboard protocol if an app exited without cleanup
# # https://github.com/anthropics/claude-code/issues/38761
# _kitty_keyboard_reset() { printf '\e[<u'; }
# case "${ZSH_VERSION:+z}${BASH_VERSION:+b}" in
# z) precmd_functions+=(_kitty_keyboard_reset) ;;
# b) PROMPT_COMMAND="_kitty_keyboard_reset${PROMPT_COMMAND:+;$PROMPT_COMMAND}" ;;
# esac
