#!/bin/bash
# Caddyfile: {{ include (joinPath .chezmoi.homeDir ".config/caddy/Caddyfile") | sha256sum }}
set -euo pipefail

if ! command -v caddy >/dev/null; then
  echo >&2 "caddy not found; skipping setup"
  exit 0
fi

caddyfile="${CHEZMOI_CADDY_CONFIG:-$HOME/.config/caddy/Caddyfile}"
caddy_data="${CHEZMOI_CADDY_DATA:-$(brew --prefix)/var/lib/caddy}"

caddy validate --config "$caddyfile"

# Start Caddy as root if not already running (root service, requires sudo list)
if ! sudo brew services list | grep -q "^caddy.*started"; then
  sudo brew services start caddy
fi

# CA cert is root-owned (600); use sudo to check existence
ca_cert="$caddy_data/pki/authorities/local/root.crt"
if ! sudo test -f "$ca_cert"; then
  echo >&2 "Caddy CA not found; check: sudo brew services info caddy"
  exit 1
fi

# macOS keychain (Safari, Chrome): uncomment if caddy trust alone is insufficient
# sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain "$ca_cert"
caddy trust --ca local --config "$caddyfile"
