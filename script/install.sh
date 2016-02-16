#!/usr/bin/env bash

# install.sh

install_packages() {
  case $UNAME in
    Darwin)
      install_brew && \
        install_cask && \
        install_cask_settings
      ;;
    *)
      log_warn "No packages" ":("
      ;;
  esac
}

install_brew() {
  local brew=$(which brew) # /usr/local/bin/brew

  if [[ ! -n "$brew" ]] || [[ ! -x "$brew" ]]; then
    log_info "Homebrew" "Installing"

    # Install the correct homebrew for each OS type
    case $UNAME in
      Darwin)
        ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
        ;;
      Linux)
        ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/linuxbrew/go/install)"
        ;;
      *)
        die "Unknown platform: $UNAME"
        ;;
    esac

    log_success "Homebrew" "Installed"
  fi

  if [[ -x "$brew" ]]; then
    if confirm "Homebrew packages" "" N; then
      # Check exit statuses?

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
      #"$DOT_ROOT/os/darwin/brewfile" #caskfile?

      # # Remove outdate version from the cellar
      log "> brew cleanup" "Cleaning"
      brew cleanup

      #brew doctor

      log_success "Homebrew"
    fi
  else
    log_error "Could not execute $brew"
    return 1
  fi
}

install_cask() {
  echo "TODO: Brewfile && Caskfile"
}

install_cask_settings() {
  local cask_path="$DOT_ROOT/os/darwin/cask"
  local name
  # open /Applications/$app.app

  if confirm "Homebrew cask settings" "${cask_path}/*" Y; then
    for cask in ${cask_path}/*; do
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
