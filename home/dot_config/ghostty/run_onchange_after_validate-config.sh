#!/bin/sh

# https://ghostty.org/docs/install/binary

set -eu

. "$CHEZMOI_WORKING_TREE/home/.chezmoitemplates/helpers.sh"

cmd ghostty +validate-config
