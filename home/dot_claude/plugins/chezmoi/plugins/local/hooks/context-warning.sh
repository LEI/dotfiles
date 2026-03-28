#!/bin/sh
# PreToolUse hook: context usage awareness
# Reads per-session JSON written by the statusline wrapper
# File: $XDG_STATE_HOME/claude/sessions/<session_id>.json
#
# Statusline used_percentage excludes system overhead (tools, rules, MCP)
# which adds 15-20%. Tiers are calibrated against auto-compact (~75%).
# Manual /compact at 55-65% produces better summaries than auto-compact.

INPUT=$(cat)
SID=$(printf '%s' "$INPUT" | jq -r '.session_id // empty' 2>/dev/null)
[ -n "$SID" ] || exit 0

FILE="${XDG_STATE_HOME:-$HOME/.local/state}/claude/sessions/$SID.json"
[ -f "$FILE" ] || exit 0

# Single jq call: percentage, human-readable usage, cost, raw token count
eval "$(jq -r '
  def human_tokens: . / 1000 | floor | tostring + "K";
  def human_total: . / 1000000 * 10 | floor / 10 | tostring + "M";
  .context_window as $cw | .cost as $c |
  ($cw.current_usage
    | .input_tokens + .output_tokens
      + .cache_creation_input_tokens + .cache_read_input_tokens) as $raw |
  "PCT=\($cw.used_percentage // 0)" ,
  "RAW=\($raw)" ,
  "USAGE=\($raw | human_tokens)/\($cw.context_window_size | human_total)" ,
  "COST=\($c.total_cost_usd // "?")"
' "$FILE" 2>/dev/null)"

[ -n "$PCT" ] || exit 0

# Absolute threshold: warn at 300K tokens regardless of percentage
# Percentage tiers calibrated for 1M window; absolute catches smaller windows
ABS_WARN=300000

if [ "$PCT" -ge 65 ] 2>/dev/null; then
  MSG="Context urgent ${PCT}%  ${USAGE} (\$${COST}): auto-compact imminent. Persist findings now."
elif [ "$PCT" -ge 55 ] 2>/dev/null; then
  MSG="Context warning ${PCT}%  ${USAGE}: approaching auto-compact. Run /compact proactively."
elif [ "$PCT" -ge 40 ] 2>/dev/null || [ "${RAW:-0}" -ge "$ABS_WARN" ] 2>/dev/null; then
  MSG="Context ${PCT}%  ${USAGE}."
else
  exit 0
fi

echo >&2 "context-warning: $MSG"

jq -n --arg msg "$MSG" '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    permissionDecision: "allow",
    additionalContext: $msg
  }
}'
