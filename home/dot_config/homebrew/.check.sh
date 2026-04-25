#!/bin/sh

set -eu

if [ -x /home/linuxbrew/.linuxbrew/bin/brew ] && ! command -v brew >/dev/null; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# TODO: ignore deprecated or disabled warnings for pinned packages
# and Tier 2 configuration warning on Fedora Silverblue
# Warning: Your /home directory is a symlink.
brew doctor || echo "WARN: brew doctor exited with code $?" >&2
