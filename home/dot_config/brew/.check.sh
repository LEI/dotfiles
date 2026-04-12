#!/bin/sh
set -eu

# TODO: ignore deprecated or disabled warnings for pinned packages
# and Tier 2 configuration warning on Fedora Silverblue
# Warning: Your /home directory is a symlink.
brew doctor || echo "WARN: brew doctor exited with code $?" >&2
