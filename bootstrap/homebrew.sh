# #!/usr/bin/env bash
#
# # homebrew.sh

# Check for Homebrew
if test ! $(which brew); then
  printf "%s\r\n" "Installing Homebrew"

  # Install the correct homebrew for each OS type
  if test "$(uname)" = "Darwin"; then
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  elif test "$(expr substr $(uname -s) 1 5)" = "Linux"; then
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/linuxbrew/go/install)"
  fi

fi

# TAPS=(
#   homebrew/versions
#   # caskroom/versions
# )
#
# FORMULAS=(
#   # Install GNU utilities
#   coreutils
#   # Useful utilities like 'sponge'
#   moreutils
#   # GNU 'find', 'locate', 'updatedb', and 'xargs', 'g'-prefixed
#   findutils
#   # Install GNU 'sed', overwriting the built-in 'sed'
#   "gnu-sed --default-names"
#   # Install Bash 4
#   # Note: add '/usr/local/bin/bash' to '/etc/shells' before running 'chsh'
#   bash
#   bash-completion
#   # Install wget with IRI support
#   "wget --enable-iri"
#
#   # Install more recent versions of some OS X tools
#   "vim --override-system-vi"
#   homebrew/dupes/grep
#   homebrew/dupes/screen
#
#   git
#   # git-flow
#
#   nmap
#   #node # --npm?
#
#   tree
#
#   # Install Caskroom
#   caskroom/cask/brew-cask
# )
#
# CASKS=(
#   # Browsers
#   google-chrome
#   firefox
#   torbrowser
#
#   # Editors
#   atom
#   mou
#
#   # Development
#   vagrant
#   virtual-box
#   transmit
#   sequel-pro
#   robomongo
#
#   # Utilities
#   # atext
#   # alfred
#   # bartender
#   caffeine
#   # kaleidoscope
#   # reggy
#   # satellite-eyes
#   # the-unarchiver
#   vlc
#   # cakebrew
#   dropbox
#   # evernote
#   little-snitch
#   skype
#   transmission
#   # ...
# )
#
# homebrew() {
#   [[ -x "/usr/local/bin/brew" ]] || {
#     # Install Homebrew
#     ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
#   }
#
#   # Make sure we're using the latest Homebrew
#   brew update
#   # # Upgrade any already installed formulae
#   brew upgrade
#   #
#   # run "brew tap" "${TAPS[@]}"
#   # run "brew install" "${FORMULAS[@]}"
#   # run "brew cask install --appdir=/Applications" "${CASKS[@]}"
#   #
#   # # Remove outdate version from the cellar
#   # brew cleanup
#   #
#   # #brew doctor
# }
#
# run() {
#   local cmd="$1"
#   local list="$2"
#
#   for item in "${list[@]}"; do
#     $cmd $item
#   done
# }
#
# echo "$0"
# [[ "$0" == "$BASH_SOURCE" ]] && homebrew "$@"
