#!/bin/sh

# nvim python3 host in an isolated uv venv, decoupled from the OS package.
# nvim reads it via g:python3_host_prog, see lua/config/init.lua.

set -eu

lib_dir="$CHEZMOI_WORKING_TREE/home/dot_local/lib"
# shellcheck source=home/dot_local/lib/sh/log.sh
. "$lib_dir/sh/log.sh"
# shellcheck source=home/dot_local/lib/sh/run.sh
. "$lib_dir/sh/run.sh"

if ! has uv; then
  warn "uv not found, skipping nvim python3 host"
  exit 0
fi

venv="${XDG_DATA_HOME:-$HOME/.local/share}/nvim/py-host"
dry_run uv venv --quiet "$venv"
dry_run uv pip install --quiet --python "$venv/bin/python" pynvim
