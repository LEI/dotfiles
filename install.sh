#!/bin/bash
# install.sh

# DOTFILES_ROOT="${BASH_SOURCE[0]%/*}"
# [ -f "$DOTFILES_ROOT" ] && DOTFILES_ROOT=$(dirname "$DOTFILES_ROOT")

cd $(dirname "${BASH_SOURCE[0]}")
DOTFILES_ROOT=$(pwd -P)

source dot/bootstrap.sh "$@" && echo "Done." || echo "Fail!"
