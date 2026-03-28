brew_i() { brew install "$@"; }
brew_installed() { brew list --installed-on-request "$@"; }
brew_tree() { brew deps --tree --installed "$@"; }
brew_u() { brew update "$@" && brew upgrade "$@"; }
brew_why() { brew uses --installed "$@"; }
