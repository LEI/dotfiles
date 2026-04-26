#!/bin/sh
# PreToolUse hook: context usage display

INPUT=$(cat)
SID=$(printf '%s' "$INPUT" | jq -r '.session_id // empty' 2>/dev/null)
[ -n "$SID" ] || exit 0

FILE="${XDG_STATE_HOME:-$HOME/.local/state}/claude/sessions/$SID.json"
[ -f "$FILE" ] || exit 0

eval "$(jq -r '
  def format_tokens: . / 1000 | floor | tostring + "K";
  def format_window: . / 1000000 * 10 | floor / 10 | tostring + "M";
  .context_window as $cw | .cost as $c |
  ($cw.current_usage | .input_tokens + .output_tokens
    + .cache_creation_input_tokens + .cache_read_input_tokens) as $tokens |
  "PCT=\($cw.used_percentage // 0)",
  "USAGE=\($tokens | format_tokens)/\($cw.context_window_size | format_window)",
  "COST=\($c.total_cost_usd // \"?\")"
' "$FILE" 2>/dev/null)"

[ -n "$PCT" ] || exit 0
[ "$PCT" -ge 50 ] 2>/dev/null || exit 0

jq -n --arg msg "Context ${PCT}%  ${USAGE} (\$${COST})" '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    permissionDecision: "allow",
    additionalContext: $msg
  }
}'
