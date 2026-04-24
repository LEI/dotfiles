# Resume last session by default
claude() {
  if [ $# -eq 0 ]; then
    set -- --continue
  fi
  command claude "$@"
}

alias claudes=claude-sessions
alias claudet=claude-teams
alias claudett=claude-teams_tmux

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
  if [ $# -eq 0 ] && [ -t 0 ]; then
    set -- --count=100 --include-forks --list --min-turns=0
  fi
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
# Override: TMUX_SESSION=custom claude-teams-tmux
claude-teams-tmux() {
  if ! type tmux_session >/dev/null 2>&1; then
    echo "tmux_session not defined; source tmux/init.sh" >&2
    return 1
  fi
  local session_name="${TMUX_SESSION:-$(basename "$PWD")}"
  tmux_session "$session_name" claude --teammate-mode=tmux "$@"
}

claude-plan() {
  local name="$1"
  shift
  local plan=".claude/plans/$name"
  if [ ! -f "$plan" ]; then
    echo "claude-plan: not found: $plan" >&2
    return 1
  fi
  command claude --permission-mode=default /plan "$plan" "$@"
}

# claude-print() {
#   command claude --print "$@"
# }

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

  local claude_dir="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
  local cdata
  cdata=$(chezmoi data --no-tty)
  local provider="${CLAUDE_PROVIDER:-zai}"
  # local name="${provider%%-*}" # yq -r '.claude.providers | keys | .[0]' <<<"$cdata"
  if [ -n "$provider" ]; then
    local base_url key
    base_url=$(yq -r ".claude.providers[\"$provider\"].url" <<<"$cdata")
    if [ "$base_url" == "null" ]; then
      base_url=
    fi
    if [ -z "$base_url" ]; then
      echo "check-ai: no URL found for provider '$provider'" >&2
      return 1
    fi
    key=$("$claude_dir/api-key-helper.sh" "$provider")
    if [ -z "$key" ]; then
      echo "check-ai: no API key found for provider '$provider'" >&2
      return 1
    fi
    set -- env ANTHROPIC_BASE_URL="$base_url" ANTHROPIC_AUTH_TOKEN="$key" "$@"
  fi
  # echo "$@" >&2
  "$@"
}

# # Pop Kitty keyboard protocol if an app exited without cleanup
# # https://github.com/anthropics/claude-code/issues/38761
# _kitty_keyboard_reset() { printf '\e[<u'; }
# case "${ZSH_VERSION:+z}${BASH_VERSION:+b}" in
# z) precmd_functions+=(_kitty_keyboard_reset) ;;
# b) PROMPT_COMMAND="_kitty_keyboard_reset${PROMPT_COMMAND:+;$PROMPT_COMMAND}" ;;
# esac
