#!/usr/bin/env bash

# install.sh

install() {
  install_homebrew
  install_cask
}

install_homebrew() {
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
      log_exec "brew update" "Updating"
      brew update

      # Upgrade any already installed formulae
      log_exec "brew upgrade" "Upgrading"
      brew upgrade

      # brew tap Homebrew/bundle
      log_exec "brew bundle" "Bundling"
      #brew bundle
      #TODO: DOT_CONFIG_BREW&CASK?
      # https://github.com/Homebrew/homebrew-bundle
      # https://github.com/caskroom/homebrew-cask

      # # Remove outdate version from the cellar
      log_exec "brew cleanup" "Cleaning"
      brew cleanup

      brew doctor

      log_success "Brewfile"
    fi
  else
    log_error "Could not execute $brew"
    return 1
  fi
}

install_cask() {
  local cask_root="$DOT_ROOT/cask"
  local name
  # open /Applications/$app.app

  if confirm "Brew cask init" "$DOT_ROOT/cask/*" Y; then
    for cask in $cask_root/*; do
      [[ ! -f "$cask" ]] && return 1

      # Capitalize cask name
      name=${cask##*/} # Remove path
      # name=${name%.*} # Remove extension
      name="$(echo "${name:0:1}" | tr "[:lower:]" "[:upper:]")${name:1}"

      # Use cask apps cli to setup defaults
      log_info "$name" "$cask"
      if source "$cask"; then
        log_success "$name"
      else
        log_error "An error occurred"
      fi
    done
  fi
}

install
