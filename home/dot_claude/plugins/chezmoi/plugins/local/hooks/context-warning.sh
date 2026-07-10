#!/bin/sh
# PreToolUse hook: context usage display, triggers on percentage or absolute token count

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
  "PCT=\($cw.used_percentage // 0 | floor)",
  "USAGE=\($tokens | format_tokens)/\($cw.context_window_size | format_window)",
  "COST=\($c.total_cost_usd // "?")",
  "ABS=\($cw.total_input_tokens // 0)"
' "$FILE" 2>/dev/null)"

[ -n "$PCT" ] || exit 0

PCT_HIT=0
ABS_HIT=0
[ "$PCT" -ge 50 ] 2>/dev/null && PCT_HIT=1
[ -n "$ABS" ] && [ "$ABS" -ge 200000 ] 2>/dev/null && ABS_HIT=1
[ "$PCT_HIT" -eq 1 ] || [ "$ABS_HIT" -eq 1 ] || exit 0

jq -n --arg msg "Context ${PCT}%  ${USAGE} (\$${COST}), context is large, a natural point to persist durable findings" '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    permissionDecision: "allow",
    additionalContext: $msg
  }
}'
