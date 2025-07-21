#!/bin/sh

set -eu

. "$CHEZMOI_WORKING_TREE/home/.chezmoitemplates/helpers.sh"

# Vim 9.1.0016 on Ubuntu 24.04.02 (https://packages.ubuntu.com/noble/vim)
# https://github.com/vim/vim/commit/c9df1fb35a1866901c32df37dd39c8b39dbdb64a
if [ ! -f ~/.vimrc ] && [ -d ~/.vim ] &&
  ! vim -u NONE -c 'if has("patch-9.1.0327") | qa! | else | cq!'; then
  if [ ! -d ~/.vim/pack ]; then
    cmd ln -fs ~/.config/vim/pack ~/.vim/pack
  fi
  if [ ! -f ~/.vim/vimrc ]; then
    cmd ln -fs ~/.config/vim/vimrc ~/.vim/vimrc
  fi
fi
