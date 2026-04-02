#!/bin/sh
set -eu

timeout 5m "$HOME/.config/tmux/plugins/tpm/bin/update_plugins" all
