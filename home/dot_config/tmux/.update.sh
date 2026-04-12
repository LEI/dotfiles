#!/bin/sh

set -eux

timeout 5m "$HOME/.config/tmux/plugins/tpm/bin/update_plugins" all >/dev/null
