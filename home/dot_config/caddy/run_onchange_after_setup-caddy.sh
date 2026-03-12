#!/bin/bash
# Caddyfile: {{ include (joinPath .chezmoi.homeDir ".config/caddy/Caddyfile") | sha256sum }}
set -euo pipefail

. "$CHEZMOI_WORKING_TREE/home/.chezmoitemplates/helpers.sh"

if ! command -v caddy >/dev/null; then
  msg "caddy not found; skipping setup"
  exit 0
fi

caddyfile="${CHEZMOI_CADDY_CONFIG:-$HOME/.config/caddy/Caddyfile}"

run caddy validate --config "$caddyfile"

# Service management by install method:
# - macOS: sudo brew services (needs root to bind port 443)
# - Linux brew fallback: brew services (user-level, no port 443 without setcap)
# - Linux system package (Fedora, Arch): root service with CAP_NET_BIND_SERVICE
if [[ "$(uname -s)" == Darwin ]]; then
  if ! sudo brew services list | grep -q "^caddy.*started"; then
    run sudo brew services start caddy
  fi
elif command -v brew >/dev/null && brew list caddy >/dev/null 2>&1; then
  if ! brew services list | grep -q "^caddy.*started"; then
    run brew services start caddy
  fi
else
  # Copy user Caddyfile to /etc/caddy/Caddyfile so the system caddy service
  # can read it without any home directory access.
  current=$(cat /etc/caddy/Caddyfile 2>/dev/null || true)
  expected=$(cat "$caddyfile")
  if [ "$current" != "$expected" ]; then
    msg "Updating /etc/caddy/Caddyfile"
    run sudo cp "$caddyfile" /etc/caddy/Caddyfile
    if systemctl is-active --quiet caddy; then
      run sudo systemctl reload caddy
    fi
  fi

  # Route .test queries to 127.0.0.1 via NetworkManager's built-in dnsmasq.
  nm_conf=/etc/NetworkManager/conf.d/dnsmasq.conf
  nm_dnsmasq=/etc/NetworkManager/dnsmasq.d/test.conf
  nm_changed=false
  if [ "$(cat "$nm_conf" 2>/dev/null || true)" != "$(printf '[main]\ndns=dnsmasq\n')" ]; then
    msg "Enabling NetworkManager dnsmasq mode"
    printf '[main]\ndns=dnsmasq\n' | run sudo tee "$nm_conf" >/dev/null
    nm_changed=true
  fi
  if [ "$(cat "$nm_dnsmasq" 2>/dev/null || true)" != "$(printf 'address=/.test/127.0.0.1\n')" ]; then
    msg "Updating $nm_dnsmasq"
    run sudo mkdir -p "$(dirname "$nm_dnsmasq")"
    printf 'address=/.test/127.0.0.1\n' | run sudo tee "$nm_dnsmasq" >/dev/null
    nm_changed=true
  fi
  if [ "$nm_changed" = true ]; then
    run sudo systemctl restart NetworkManager
  fi

  if ! systemctl is-active --quiet caddy; then
    run sudo systemctl enable --now caddy || {
      sudo journalctl -u caddy -n 50 --no-pager >&2
      exit 1
    }
  fi
fi

if ! curl -sf http://localhost:2019/pki/ca/local >/dev/null 2>&1; then
  msg "Caddy CA not ready; run chezmoi apply again after caddy initializes"
  exit 0
fi

# macOS keychain (Safari, Chrome): uncomment if caddy trust alone is insufficient
# sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain \
#   "$(brew --prefix)/var/lib/caddy/pki/authorities/local/root.crt"
run caddy trust --ca local # --config "$caddyfile"
