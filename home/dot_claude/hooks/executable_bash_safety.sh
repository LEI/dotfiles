#!/bin/bash

# PreToolUse hook: flag dangerous Bash commands for confirmation
# Exit 0 with no output: allow (default mode handles permission)
# Exit 0 with JSON: override to ask with reason

INPUT=$(cat)
CMD=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
[[ -z "$CMD" ]] && exit 0

REASONS=()

check() {
  local pattern="$1" reason="$2"
  if echo "$CMD" | grep -qE "$pattern"; then
    REASONS+=("$reason")
  fi
}

# Filesystem destruction
check '\brm\b.*\s-[a-zA-Z]*r' "recursive rm"
check '\btrash\b.*/' "bulk trash"
check '\bmkfs\b' "filesystem format"
check '\bdd\b.*\bif=' "raw disk write"

# Git destructive ops
check '\bgit\b.*\bpush\b.*--force' "force push"
check '\bgit\b.*\breset\b.*--hard' "hard reset"
check '\bgit\b.*\bclean\b.*-[a-zA-Z]*f' "git clean -f"
check '\bgit\b.*\bbranch\b.*-D\b' "branch force delete"
check '\bgit\b.*\bcheckout\b.*-- \.' "discard all changes"
check '\bgit\b.*\brestore\b.*-- \.' "discard all changes"

# Chezmoi danger
check '\bchezmoi\b.*\b(init|apply)\b' "chezmoi init/apply from agent"

# Privilege escalation and system changes
check '\bsudo\b' "sudo"
check '\bchmod\b.*777' "world-writable permissions"
check '\bcurl\b.*\|\s*(ba)?sh' "pipe to shell"
check '\bwget\b.*\|\s*(ba)?sh' "pipe to shell"

# Output destruction
check '>\s*/dev/(sd|disk|nvme)' "write to block device"
check '\bkill\b.*-9' "SIGKILL"
check '\bkillall\b' "killall"
check '\bpkill\b' "pkill"

[[ ${#REASONS[@]} -eq 0 ]] && exit 0

WARN=$(printf "%s; " "${REASONS[@]}")
WARN="${WARN%; }"

jq -n --arg reason "Flagged: $WARN" '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    permissionDecision: "ask",
    permissionDecisionReason: $reason
  }
}'
