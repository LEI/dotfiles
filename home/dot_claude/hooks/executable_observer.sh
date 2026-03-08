#!/bin/bash

# Observer hook: structured JSONL logging of lifecycle events
# Pure observer; exits 0 with no stdout

INPUT=$(cat)
EVENT="${CLAUDE_HOOK_EVENT_NAME:-unknown}"
TIMESTAMP=$(date -u '+%Y-%m-%dT%H:%M:%SZ')
SESSION=$(echo "$INPUT" | jq -r '.session_id // empty')

LOG_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/claude"
mkdir -p "$LOG_DIR"
echo "$INPUT" | jq -c \
  --arg ts "$TIMESTAMP" \
  --arg ev "$EVENT" \
  --arg sid "$SESSION" \
  '{ts: $ts, event: $ev, session: $sid} + .' \
  >> "$LOG_DIR/hooks.jsonl"
