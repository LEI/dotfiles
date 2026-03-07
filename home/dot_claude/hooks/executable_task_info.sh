#!/bin/bash

# PreToolUse hook: show task details in ask prompt
# Matches TaskCreate and TaskUpdate
#
# Formatting: plain text only (no markdown, no ANSI)
# Newlines work across all UIs (CLI, VS Code, JetBrains, web)
# "ask" reason shown to user only; "deny" reason shown to Claude only
#
# Icons (matching Claude Code task list): ◻ pending, ◼ in_progress, ✔ completed
# Actions: + Create, △ Update, ✕ Delete

INPUT=$(cat)
TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty')
[[ -z "$TOOL" ]] && exit 0

TASKS_DIR="$HOME/.claude/tasks"

find_task() {
  fd -t f "${1}.json" "$TASKS_DIR" 2>/dev/null | head -1
}

list_id_from_path() {
  local path="$1"
  echo "${path#"$TASKS_DIR/"}" | cut -d/ -f1
}

status_icon() {
  case "$1" in
    pending) echo "◻" ;;
    in_progress) echo "◼" ;;
    completed) echo "✔" ;;
    *) echo "?" ;;
  esac
}

# "N tasks (X done, Y in progress, Z open)"
list_summary() {
  local list_dir="$1"
  [[ -d "$list_dir" ]] || return
  jq -s '
    length as $total |
    [.[] | .status] | group_by(.) | map({(.[0]): length}) | add // {} |
    .completed // 0 | tostring | . as $done |
    input | .in_progress // 0 | tostring | . as $prog |
    input | . - (.completed // 0) - (.in_progress // 0) | tostring | . as $open |
    empty
  ' "$list_dir"/*.json 2>/dev/null && return
  # Fallback: simple loop
  local total=0 done=0 open=0 prog=0
  for f in "$list_dir"/*.json; do
    [[ -f "$f" ]] || continue
    (( total++ ))
    case "$(jq -r '.status' "$f" 2>/dev/null)" in
      completed) (( done++ )) ;;
      in_progress) (( prog++ )) ;;
      *) (( open++ )) ;;
    esac
  done
  local parts=""
  (( done )) && parts="$done done"
  (( prog )) && parts="${parts:+$parts, }$prog in progress"
  (( open )) && parts="${parts:+$parts, }$open open"
  echo "$total tasks ($parts)"
}

# Dump full hook input (all keys, tool_input expanded)
pretty_input() {
  echo "$INPUT" | jq -r '
    to_entries[] |
    if .key == "tool_input" then
      "  tool_input:",
      (.value | to_entries[] | "    \(.key): \(.value | tostring | .[0:200])")
    else
      "  \(.key): \(.value | tostring | .[0:200])"
    end'
}

# Dump on-disk task JSON
pretty_disk() {
  local file="$1"
  [[ -f "$file" ]] || return
  jq -r 'to_entries[] | "    \(.key): \(.value | tostring | .[0:200])"' "$file"
}

# Word-level diff of two strings via git
word_diff() {
  local old="$1" new="$2"
  local tmp_a tmp_b
  tmp_a=$(mktemp) tmp_b=$(mktemp)
  trap 'rm -f "$tmp_a" "$tmp_b"' RETURN
  printf '%s\n' "$old" > "$tmp_a"
  printf '%s\n' "$new" > "$tmp_b"
  git diff --no-ext-diff --no-index --word-diff=plain --no-color \
    -- "$tmp_a" "$tmp_b" 2>/dev/null | tail -n +6 | head -c 500
}

case "$TOOL" in
  TaskCreate)
    SUBJECT=$(echo "$INPUT" | jq -r '.tool_input.subject // "?"')
    STATUS=$(echo "$INPUT" | jq -r '.tool_input.status // "pending"')

    REASON="+ Create $(status_icon "$STATUS") [$STATUS] $SUBJECT
  --- input:
$(pretty_input)"
    ;;

  TaskUpdate)
    ID=$(echo "$INPUT" | jq -r '.tool_input.taskId // "?"')
    TASK_FILE=$(find_task "$ID")

    if [[ -n "$TASK_FILE" && -f "$TASK_FILE" ]]; then
      LIST_ID=$(list_id_from_path "$TASK_FILE")
      LIST_DIR="$TASKS_DIR/$LIST_ID"
      CUR_SUBJECT=$(jq -r '.subject // ""' "$TASK_FILE")
      CUR_STATUS=$(jq -r '.status // ""' "$TASK_FILE")
      CUR_DESC=$(jq -r '.description // ""' "$TASK_FILE")

      NEW_STATUS=$(echo "$INPUT" | jq -r '.tool_input.status // empty')

      # First line: action + current state
      if [[ "$NEW_STATUS" == "deleted" ]]; then
        REASON="✕ Delete $(status_icon "$CUR_STATUS") [$CUR_STATUS] $CUR_SUBJECT"
      else
        CHANGES=""

        if [[ -n "$NEW_STATUS" && "$NEW_STATUS" != "$CUR_STATUS" ]]; then
          CHANGES="$(status_icon "$CUR_STATUS") [$CUR_STATUS] → $(status_icon "$NEW_STATUS") [$NEW_STATUS]"
        fi

        NEW_SUBJECT=$(echo "$INPUT" | jq -r '.tool_input.subject // empty')
        if [[ -n "$NEW_SUBJECT" && "$NEW_SUBJECT" != "$CUR_SUBJECT" ]]; then
          [[ -n "$CHANGES" ]] && CHANGES="$CHANGES, "
          CHANGES="${CHANGES}subject → $NEW_SUBJECT"
        fi

        # Description word-diff
        NEW_DESC=$(echo "$INPUT" | jq -r '.tool_input.description // empty')
        DESC_DIFF=""
        if [[ -n "$NEW_DESC" && "$NEW_DESC" != "$CUR_DESC" ]]; then
          WDIFF_OUT=$(word_diff "$CUR_DESC" "$NEW_DESC")
          [[ -n "$WDIFF_OUT" ]] && DESC_DIFF="  description:
  $WDIFF_OUT"
        fi

        if [[ -n "$CHANGES" ]]; then
          REASON="△ Update $(status_icon "$CUR_STATUS") [$CUR_STATUS] $CUR_SUBJECT
  $CHANGES"
        else
          REASON="△ Update $(status_icon "$CUR_STATUS") [$CUR_STATUS] $CUR_SUBJECT"
        fi

        [[ -n "$DESC_DIFF" ]] && REASON="$REASON
$DESC_DIFF"
      fi

      SUMMARY=$(list_summary "$LIST_DIR")
      REASON="$REASON
  --- input:
$(pretty_input)
  --- on disk:
$(pretty_disk "$TASK_FILE")
  list: $LIST_ID${SUMMARY:+ | $SUMMARY}"
    else
      REASON="△ Update task #$ID (file not found)
  --- input:
$(pretty_input)"
    fi
    ;;

  *) exit 0 ;;
esac

jq -n --arg reason "$REASON" '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    permissionDecision: "ask",
    permissionDecisionReason: $reason
  }
}'
