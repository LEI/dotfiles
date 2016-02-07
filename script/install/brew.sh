#!/usr/bin/env bash

# brew.sh

install_brew() {
  local brew=$(which brew) # /usr/local/bin/brew

  if [[ ! -n "$brew" ]] || [[ ! -x "$brew" ]]; then
    log_info "Homebrew" "Installing"

    # Install the correct homebrew for each OS type
    case $UNAME in
      darwin)
        ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
        ;;
      linux)
        ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/linuxbrew/go/install)"
        ;;
      *)
        die "Unknown platform: $UNAME"
        ;;
    esac

    log_success "Homebrew" "Installed"
  fi

  if [[ -x "$brew" ]]; then
    if confirm "Brew bundle" "$DOT_ROOT/Brewfile" N; then
      # Make sure we're using the latest Homebrew
      log "> brew update" "Updating"
      brew update

      # Upgrade any already installed formulae
      log "> brew upgrade" "Upgrading"
      brew upgrade

      # brew tap Homebrew/bundle
      log "> brew bundle" "Bundling"
      #brew bundle
      #TODO: DOT_CONFIG_BREW&CASK?
      # https://github.com/Homebrew/homebrew-bundle
      # https://github.com/caskroom/homebrew-cask

      # # Remove outdate version from the cellar
      log "> brew cleanup" "Cleaning"
      brew cleanup

      brew doctor

      log_success "Brewfile"
    fi
  else
    log_error "Could not execute $brew"
    return 1
  fi
}
