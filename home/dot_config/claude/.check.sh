#!/bin/sh

set -eu

lib_dir="$HOME/.local/lib"
# shellcheck source=home/dot_local/lib/sh/log.sh
. "$lib_dir/sh/log.sh"

# if command -v claude >/dev/null; then
#   trace claude doctor
# fi

# NOTE: /Applications/Claude.app/Contents/MacOS/Claude is GUI only
if command -v claude-desktop >/dev/null; then
  trace claude-desktop --doctor
fi
