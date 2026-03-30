#!/bin/sh
#MISE description="Run brew doctor"

set -eu

# TODO: ignore deprecated or disabled warnings for pinned packages
# and Tier 2 configuration warning on Fedora Silverblue
# Warning: Your /home directory is a symlink.
brew doctor || echo >&2 "WARN: brew doctor exited with code $?"
