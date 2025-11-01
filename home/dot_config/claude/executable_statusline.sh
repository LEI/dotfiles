#!/bin/bash

set -euo pipefail

# https://docs.anthropic.com/en/docs/claude-code/statusline

# Read JSON input from stdin
input=$(cat)

# Show git branch if in a git repo
GIT_BRANCH=""
if git rev-parse --git-dir >/dev/null 2>&1; then
  BRANCH=$(git branch --show-current 2>/dev/null)
  if [ -n "$BRANCH" ]; then
    GIT_BRANCH=" | Branch: $BRANCH"
  fi
fi

get_model_name() { echo "$input" | jq -r '.model.display_name'; }
get_current_dir() { echo "$input" | jq -r '.workspace.current_dir'; }
get_project_dir() { echo "$input" | jq -r '.workspace.project_dir'; }
get_version() { echo "$input" | jq -r '.version'; }
get_cost() { echo "$input" | jq -r '.cost.total_cost_usd'; }
get_duration() { echo "$input" | jq -r '.cost.total_duration_ms'; }
get_lines_added() { echo "$input" | jq -r '.cost.total_lines_added'; }
get_lines_removed() { echo "$input" | jq -r '.cost.total_lines_removed'; }

MODEL=$(get_model_name)
DIR=$(get_current_dir)
PROJECT=$(get_current_dir)
VERSION=$(get_version)
COST=$(get_cost)
DURATION=$(get_duration)
ADDED=$(get_lines_added)
REMOVED=$(get_lines_removed)
echo "[$MODEL] Directory: ${DIR##*/}$GIT_BRANCH | Project: $PROJECT | Version: $VERSION | Cost: $COST | Duration: $DURATION | Added: $ADDED | Removed: $REMOVED"
