#!/bin/bash

# Observer hook: structured JSONL logging of lifecycle events
# Pure observer; exits 0 with no stdout

INPUT=$(cat)
EVENT=$(echo "$INPUT" | jq -r '.hook_event_name // empty')
EVENT="${EVENT:-${CLAUDE_HOOK_EVENT_NAME:-unknown}}"
TIMESTAMP=$(date -u '+%Y-%m-%dT%H:%M:%SZ')
SESSION=$(echo "$INPUT" | jq -r '.session_id // empty')

LOG_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/claude"
mkdir -p "$LOG_DIR"
echo "$INPUT" | jq -c \
  --arg ts "$TIMESTAMP" \
  --arg ev "$EVENT" \
  --arg sid "$SESSION" \
  '{ts: $ts, event: $ev, session: $sid, source: "observer",
    tool_name: .tool_name,
    agent_id: .agent_id,
    agent_type: .agent_type,
    is_interrupt: .is_interrupt,
    error: (.error // null | if . then (.[0:500]) else null end)}
    | with_entries(select(.value != null))' \
  >> "$LOG_DIR/hooks.jsonl"
