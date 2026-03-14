#!/bin/sh
# Appends missing env vars and secrets to local.sh
set -eu

local_sh="${XDG_CONFIG_HOME:-$HOME/.config}/sh/local.sh"

ensure_var() {
  if grep -q "^export $1=\".\+" "$local_sh" 2>/dev/null; then
    return
  fi
  printf '\nexport %s="%s"\n' "$1" "$2" >> "$local_sh"
  echo >&2 "$1 set"
}

# Static defaults
ensure_var OAGE_WEBUI_URL "https://open-webui.test"

# Random secrets
for key in OAGE_BIFROST_API_KEY OAGE_WEBUI_SECRET_KEY OPEN_NOTEBOOK_ENCRYPTION_KEY; do
  ensure_var "$key" "$(openssl rand -hex 32)"
done
