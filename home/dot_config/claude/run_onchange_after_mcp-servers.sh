#!/bin/bash

set -euo pipefail

mcp_servers="$HOME/.config/mcphub/servers.json"

for name in $(jq -r '.mcpServers | keys[]' "$mcp_servers"); do
  if claude mcp get "$name" >/dev/null 2>&1; then
    # claude mcp remove --scope=user "$name"
    continue
  fi
  claude mcp add-json --scope=user "$name" \
    "$(jq -cr ".mcpServers[\"$name\"]" "$mcp_servers")"
done

echo >&2 "claude mcp list"
claude mcp list
