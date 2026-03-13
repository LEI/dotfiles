#!/bin/bash
# Appends missing secrets to local.sh; skips keys already set
set -euo pipefail

local_sh="${XDG_CONFIG_HOME:-$HOME/.config}/sh/local.sh"

secret_keys=(
  OAGE_BIFROST_API_KEY
  OAGE_WEBUI_SECRET_KEY
  OPEN_NOTEBOOK_ENCRYPTION_KEY
)

for key in "${secret_keys[@]}"; do
  if grep -q "^export $key=\".\+" "$local_sh" 2>/dev/null; then
    echo >&2 "$key already set, skipping"
    continue
  fi
  printf '\nexport %s="%s"\n' "$key" "$(openssl rand -hex 32)" >> "$local_sh"
  echo >&2 "generated $key"
done
