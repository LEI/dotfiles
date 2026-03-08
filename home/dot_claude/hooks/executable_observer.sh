#!/bin/bash

# Observer hook: log event name and brief summary to ~/.claude/hooks.log
# Pure observer; exits 0 with no stdout

INPUT=$(cat)
EVENT="${CLAUDE_HOOK_EVENT_NAME:-unknown}"
TIMESTAMP=$(date '+%Y-%m-%dT%H:%M:%S')

case "$EVENT" in
  SubagentStart)
    DETAIL=$(echo "$INPUT" | jq -r '.agent_type // .tool_input.agent_type // "agent"')
    ;;
  SubagentStop)
    DETAIL=$(echo "$INPUT" | jq -r '.agent_type // .tool_input.agent_type // "agent"')
    ;;
  TaskCompleted)
    DETAIL=$(echo "$INPUT" | jq -r '.subject // .tool_input.subject // "task"')
    ;;
  PostToolUseFailure)
    DETAIL=$(echo "$INPUT" | jq -r '.tool_name // .tool_input.tool_name // "tool"')
    ;;
  *)
    DETAIL=$(echo "$INPUT" | jq -r '.tool_name // .event // "n/a"')
    ;;
esac

LOG_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/claude"
mkdir -p "$LOG_DIR"
echo "$TIMESTAMP $EVENT $DETAIL" >> "$LOG_DIR/hooks.log"
