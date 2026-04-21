#!/bin/sh

set -eux

timeout 5m nvim --headless -c 'lua local ok = pcall(vim.cmd, "LazyUpdate!"); os.exit(ok and 0 or 1)' >/dev/null
echo
