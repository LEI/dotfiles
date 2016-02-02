#!/usr/bin/env bash
# ubuntu.sh

# ~ github.com/captbaritone/dotfiles/blob/master/ubuntu/install.sh

command -v apt-get || exit

echo "Installing Ubuntu apt-get packages"

# For neovim
sudo add-apt-repository ppa:neovim-ppa/unstable

sudo apt-get update
sudo apt-get install --assume-yes \
    ca-certificates \
    curl \
    git \
    locate \
    lynx \
    neovim \
    php5 php5-cli \
    python-software-properties \
    mutt \
    offlineimap \
    silversearcher-ag \
    tree \
    vim \
    vim-gnome \
    weechat \
    zsh \
