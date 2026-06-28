#!/bin/sh
# PreToolUse hook: git command reminder
# Advisory only, emits additionalContext and never blocks

INPUT=$(cat)
CMD=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)
[ -n "$CMD" ] || exit 0

# Match git as an invoked command, not as a substring like digit or legit
printf '%s' "$CMD" | grep -Eq '(^|[^[:alnum:]_])git([[:space:]]|$)' || exit 0

MSG="git in the current repo: run it directly, no cd into the cwd, and use -C only for other repos."

jq -n --arg msg "$MSG" '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    permissionDecision: "allow",
    additionalContext: $msg
  }
}'
