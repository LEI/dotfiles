#!/bin/sh
# PreToolUse hook: ripgrep -r confusion guard
# Advisory only, emits additionalContext and never blocks

INPUT=$(cat)
CMD=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)
[ -n "$CMD" ] || exit 0

# Match rg as an invoked command, not as a substring like ripgrep or trg
printf '%s' "$CMD" | grep -Eq '(^|[^[:alnum:]_])rg([[:space:]]|$)' || exit 0

# Flag a bundled short flag where r is not last, e.g. -rn, -rln, -lrn: there -r
# swallows the trailing letters as its --replace value, silently disabling the
# search intent. A deliberate substitution is -r VALUE or --replace, left silent.
printf '%s' "$CMD" | grep -Eq '(^|[[:space:]])-[a-z]*r[a-z]' || exit 0

MSG="rg: -r is --replace, not recursive. rg recurses by default, drop -r; keep -r/--replace only to substitute matched text."

jq -n --arg msg "$MSG" '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    additionalContext: $msg
  }
}'
