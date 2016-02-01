#!/usr/bin/env bash

# git.sh

# git_pull() { # Sould be done before
#   git pull origin master
# }

git_submodule() {
  git add submodule "https://github.com/$1.git" "files/.vim/bundle/$2"
}

# [submodule "files/.vim/bundle/pathogen"]
# url = https://github.com/tpope/vim-pathogen.git
# [submodule "files/.vim/bundle/sensible"]
# url = https://github.com/tpope/vim-sensible.git
# [submodule "files/.vim/bundle/fugitive"]
# url = https://github.com/tpope/vim-fugitive.git
# [submodule "files/.vim/bundle/syntastic"]
# url = https://github.com/scrooloose/syntastic
# [submodule "files/.vim/bundle/base16"]
# url = https://github.com/chriskempson/base16-vim.git
# [submodule "files/.vim/bundle/nerdtree"]
# url = https://github.com/scrooloose/nerdtree.git
# [submodule "files/.vim/bundle/gitgutter"]
# url = https://github.com/airblade/vim-gitgutter.git
# [submodule "files/.vim/bundle/command-t"]
# url = https://github.com/wincent/command-t.git
# [submodule "files/.vim/bundle/ctrlp"]
# url = https://github.com/ctrlpvim/ctrlp.vim.git
# [submodule "files/.vim/bundle/airline"]
# url = https://github.com/bling/vim-airline.git
#tpope/vim-vinegar
