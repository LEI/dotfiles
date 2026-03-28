#!/bin/sh
#MISE description="Run brew doctor"

set -eu

# TODO: ignore deprecated or disabled warnings for pinned packages
brew doctor || echo >&2 "WARN: brew doctor exited with code $?"
